require 'fileutils'

DEVENV_REGEX = /^rhc-devenv-\d+/
SIBLING_REPOS = {'crankcase' => ['../crankcase-working', '../crankcase-fork', '../crankcase', '/var/lib/jenkins/jobs/crankcase/workspace'],
                 'rhc' => ['../rhc-working', '../rhc-fork', '../rhc', '/var/lib/jenkins/jobs/rhc/workspace']}
  
PACKAGE_REGEX = /^([\w\.-]*)-\d+\.\d+\.\d+-\d+\.\..*:$/
IGNORE_PACKAGES = ['bind-local', 'rubygem-rhc', 'stickshift-broker', 'rubygem-gearchanger-oddjob-plugin', 'rubygem-swingshift-mongo-plugin', 'rubygem-uplift-bind-plugin', 'openshift-origin', 'openshift-origin-broker', 'openshift-origin-node','rubygem-swingshift-kerberos-plugin']

module OpenShift
  module Tito

    def get_build_dirs
      # Figure out what needs to be built
      li_repo = {'li' => [FileUtils.pwd]}
      repos = li_repo.merge(SIBLING_REPOS)

      all_packages = get_packages
      build_dirs = []
      repos.each do |repo_name, repo_dirs|
        repo_dirs.each do |repo_dir|
          if File.exists?(repo_dir)
            packages = `cd #{repo_dir} && tito report --untagged-commits`
            packages.split("\n").each do |package|
              if package =~ PACKAGE_REGEX
                pkg = $1
                unless IGNORE_PACKAGES.include?(pkg)
                  build_dirs << [pkg, all_packages[pkg][0], all_packages[pkg][1]]
                end
              end
            end
            break
          end
        end
      end
      build_dirs
    end

    def get_sync_dirs
      # Figure out what needs to be synced
      tito_report = `tito report --untagged-commits`
      current_package = nil
      FileUtils.mkdir_p "/tmp/devenv/sync/"
      sync_dirs = []
      li_repo = {'li' => [FileUtils.pwd]}
      repos = li_repo.merge(SIBLING_REPOS)
      all_packages = get_packages
      repos.each do |repo_name, repo_dirs|
        current_package_contents = ''
        current_package = nil
        current_sync_dir = nil
        current_spec_file = nil
        repo_dirs.each do |repo_dir|
          if File.exists?(repo_dir)
            packages = `cd #{repo_dir} && tito report --untagged-commits`
            packages.split("\n").each do |package|
              if package =~ DEVENV_REGEX
                puts "The devenv package has an update but isn't being installed."
              elsif package =~ PACKAGE_REGEX
                pkg = $1
                unless IGNORE_PACKAGES.include?(pkg)
                  current_package = pkg
                  current_sync_dir = all_packages[pkg][0]
                  current_spec_file = all_packages[pkg][1]
                end
              elsif package =~ /---------------------/
                if current_package
                  update_sync_history(current_package, current_package_contents, current_sync_dir, current_spec_file, sync_dirs)
                  current_package_contents = ''
                  current_package = nil
                end
              end
              current_package_contents += package if current_package
            end
            update_sync_history(current_package, current_package_contents, current_sync_dir, current_spec_file, sync_dirs) if current_package
            break
          end
        end
      end
      sync_dirs.compact!
      sync_dirs
    end

    def get_stale_dirs
      stale_dirs = []
      packages = get_packages
      packages.each do |package_name, build_info|
        unless IGNORE_PACKAGES.include?(package_name)
          build_dir = build_info[0]
          spec_file = build_info[1]
          installed_version = `yum list installed #{package_name} | tail -n1 | gawk '{print $2}'`
          if installed_version =~ /(\d+\.\d+\.\d+)-/
            installed_version = $1
            spec_version = /Version: *(.*)/.match(File.read(spec_file))[1].strip
            installed_version_parts = installed_version.split(".").map { |part| part.to_i }
            spec_version_parts = spec_version.split(".").map { |part| part.to_i }
            stale_dirs << [package_name, build_dir, spec_file] if (installed_version_parts <=> spec_version_parts) < 0
          end
        end
      end
      stale_dirs
    end

    def get_packages(include_subpackages=false, as_obj=false)
      packages = {}
      dirs = ['.']
      SIBLING_REPOS.each do |repo_name, repo_dirs|
        repo_dirs.each do |repo_dir|
          if File.exists?(repo_dir)
            dirs << repo_dir
            break
          end
        end
      end
      dirs.each do |repo_dir|
        Dir.glob("#{repo_dir}/**/*.spec") do |file|
          unless file.start_with?('build/')
            package = Package.new(file, File.dirname(file))
            packages[package.name] = as_obj ? package : [package.dir, package.spec_path]

            if include_subpackages
              package.subpackages.each do |package|
                packages[package.name] = as_obj ? package : [package.dir, package.spec_path]
              end
            end
          end
        end
      end
      packages
    end

    class Package
      attr_reader :spec_path, :dir
      def initialize(spec_path, dir)
        @spec_path, @dir = spec_path, dir
      end
      def spec_file
        @spec_file ||= File.read(@spec_path)
      end
      def name
        @name ||= replace_globals(/Name: *(.*)/.match(spec_file)[1].strip)
      end

      def build_requires
        spec_file.lines.to_a.inject([]) do |a,s| 
          match = s.match(/^\s*BuildRequires:\s*([^\s]*)$/)
          a << match[1] if match
          a
        end
      end

      def subpackages
        @subpackages ||= begin
          package = /%package *(.*)/.match(spec_file)
          if package
            package_name = package[1].strip
            if package_name.start_with?('-n')
              package_name = package_name[2..-1]
            else
              package_name = "#{name}-#{package_name}"
            end
            package_name = replace_globals(package_name, file_str)
            [Subpackage.new(self, package_name)]
          else
            []
          end
        end
      end

      protected
        def replace_globals(s)
          while (s =~ /%\{([^\{\}]*)\}/)
            var_name = $1
            var_val = /%global *#{var_name} *(.*)/.match(spec_file)[1].strip
            s = s.gsub("%{#{var_name}}", var_val)
          end
          s
        end
    end

    class Subpackage < Package
      attr_reader :name, :parent
      def initialize(parent, name)
        @parent, @name = parent, name
      end
      [:spec_file, :spec_path, :spec_dir].each do |sym|
        define_method sym do
          parent.send(sym)
        end
      end
      def sub_packages; []; end
    end


    def update_sync_history(current_package, current_package_contents, current_sync_dir, current_spec_file, sync_dirs)
      current_package_file = "/tmp/devenv/sync/#{current_package}"
      previous_package_contents = nil
      if File.exists? current_package_file
        previous_package_contents = `cat #{current_package_file}`.chomp
      end
      unless previous_package_contents == current_package_contents
        sync_dirs << [current_package, current_sync_dir, current_spec_file]
        file = File.open(current_package_file, 'w')
        begin
          file.print current_package_contents
        ensure
          file.close
        end
      else
        puts "Latest package already installed for: #{current_package}"
      end
    end

    def next_tito_version(version, commit_id)
      #version + "-1.git.#{commit_id}"
      version + ".1"
    end

    def next_patch_version(version)
      last_index_of_dot = version.rindex('.')
      version[0..last_index_of_dot] + (version[last_index_of_dot+1..-1].to_i + 1).to_s
    end

    def next_minor_version(version)
      index_of_dot = version.index('.')
      second_index_of_dot = version.index('.', index_of_dot + 1)
      last_index_of_dot = version.rindex('.')
      next_minor_version = nil
      if version[last_index_of_dot+1..-1].to_i > 1
        next_minor_version = version[0..index_of_dot] + (version[index_of_dot + 1..second_index_of_dot].to_i + 1).to_s + ".0"
      end
      next_minor_version
    end

    def get_version(file)
      version = /Version: *(.*)/.match(File.read(file))[1].strip
    end

    def update_gemfile_version(spec_file, gem_name, gemfile, verbose)
      version = get_version(spec_file)
      nv = next_patch_version(version)
      run("/bin/sed -i 's,#{gem_name} (.*,#{gem_name} (#{nv}),' #{gemfile}", :verbose => verbose)
    end
    
    def get_yum_version(package)
      yum_output = `yum info #{package}`

      # Process the yum output to get a version
      version = yum_output.split("\n").collect do |line|
        line.split(":")[1].strip if line.start_with?("Version")
      end.compact[-1]

      # Process the yum output to get a release
      release = yum_output.split("\n").collect do |line|
        line.split(":")[1].strip if line.start_with?("Release")
      end.compact[-1]

      return "#{version}-#{release.split('.')[0]}"
    end
  end
end
