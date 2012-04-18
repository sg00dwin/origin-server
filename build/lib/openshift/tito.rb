require 'fileutils'

RUBYGEM_STICKSHIFT_REGEX = /^rubygem-stickshift-([\w]+)-\d+/
STICKSHIFT_ABSTRACT_REGEX = /^stickshift-(abstract)-\d+/
RUBYGEM_SWINGSHIFT_STREAMLINE_REGEX = /^rubygem-swingshift-streamline-plugin-\d+/
RUBYGEM_CRANKCASE_MONGO_REGEX = /^rubygem-crankcase-mongo-plugin-\d+/
RUBYGEM_UPLIFT_DYNECT_REGEX = /^rubygem-uplift-dynect-plugin-\d+/
RUBYGEM_GEARCHANGER_MCOLLECTIVE_REGEX = /^rubygem-gearchanger-m-collective-plugin-\d+/
CARTRIDGE_REGEX = /^(cartridge-[\w-]+\d+[\.\d+]*)-\d+\.\d+\.\d+-/
RHC_REGEX = /^rhc-([\w-]+)-\d+/
DEVENV_REGEX = /^rhc-devenv-\d+/
DRUPAL_REGEX = /^drupal6-openshift-([\w]+)-\d+/

module OpenShift
  module Tito
    def get_build_dirs
      # Figure out what needs to be built
      packages = `tito report --untagged-commits`
      build_dirs = packages.split("\n").collect do |package|
        if package =~ DEVENV_REGEX
          "misc/devenv"
        elsif package =~ RUBYGEM_STICKSHIFT_REGEX
          "stickshift/#{$1}"
        elsif package =~ STICKSHIFT_ABSTRACT_REGEX
          "stickshift/abstract"
        elsif package =~ RUBYGEM_SWINGSHIFT_STREAMLINE_REGEX
          "swingshift/streamline"
        elsif package =~ RUBYGEM_CRANKCASE_MONGO_REGEX
          "crankcase/mongo"
        elsif package =~ RUBYGEM_UPLIFT_DYNECT_REGEX
          "uplift/dynect"
        elsif package =~ RUBYGEM_GEARCHANGER_MCOLLECTIVE_REGEX
          "gearchanger/m-collective"
        elsif package =~ CARTRIDGE_REGEX
          "cartridges/" + $1['cartridge-'.length..-1]
        elsif package =~ RHC_REGEX
          $1
        elsif package =~ DRUPAL_REGEX
          "drupal/drupal6-openshift-#{$1}"
        end
      end.compact
      client_path = nil
      if File.exists?('../os-client-tools/express')
        client_path = '../os-client-tools/express'
        packages = `cd #{client_path} && tito report --untagged-commits`
        build_dirs += packages.split("\n").collect do |package|
          if package =~ /^rhc-[0-9]/
            client_path
          end
        end.compact
      end
      build_dirs
    end
    
    def get_stale_dirs
      stale_dirs = []
      Dir.glob("**/*.spec") do |file|
        unless file.start_with?('build/')
          build_dir = File.dirname(file)
          name = File.basename(build_dir)
          package_name = nil
          if file.start_with?('cartridges')
            package_name = "rhc-cartridge-#{name}"
          elsif file.start_with?('stickshift/abstract/')
            package_name = "stickshift-abstract"
          elsif file.start_with?('stickshift')
            package_name = "rubygem-stickshift-#{name}"
          elsif file.start_with?('swingshift/streamline/')
            package_name = "rubygem-swingshift-streamline-plugin"
          elsif file.start_with?('crankcase/mongo/')
            package_name = "rubygem-crankcase-mongo-plugin"
          elsif file.start_with?('uplift/dynect/')
            package_name = "rubygem-uplift-dynect-plugin"
          elsif file.start_with?('gearchanger/m-collective/')
            package_name = "rubygem-gearchanger-m-collective-plugin"
          elsif file.start_with?('drupal')
            package_name = "drupal6-openshift-#{name}"
          else
            package_name = "rhc-#{name}"
          end
          installed_version = `yum list installed #{package_name} | tail -n1 | gawk '{print $2}'`
          if installed_version =~ /(\d+\.\d+\.\d+)-/
            installed_version = $1
            spec_version = /Version: (.*)/.match(File.read(file))[1].strip
            installed_version_parts = installed_version.split(".").map { |part| part.to_i }
            spec_version_parts = spec_version.split(".").map { |part| part.to_i }
            if (installed_version_parts <=> spec_version_parts) < 0
              stale_dirs << [package_name, build_dir]
            end
          end
        end
      end
      stale_dirs
    end

    def get_sync_dirs
      # Figure out what needs to be synced
      tito_report = `tito report --untagged-commits`
      current_package = nil
      FileUtils.mkdir_p "/tmp/devenv/sync/"
      current_package_contents = ''
      current_package = nil
      current_sync_dir = nil
      sync_dirs = []
      packages = tito_report.split("\n")
      packages.each do |package|
        if package =~ DEVENV_REGEX
          puts "The devenv package has an update but isn't being installed."
        elsif package =~ RUBYGEM_STICKSHIFT_REGEX
          dir_name = $1
          current_package = "rubygem-stickshift-#{dir_name}"
          current_sync_dir = "stickshift/#{dir_name}"
        elsif package =~ STICKSHIFT_ABSTRACT_REGEX
          current_package = "stickshift-abstract"
          current_sync_dir = "stickshift/abstract"
        elsif package =~ RUBYGEM_SWINGSHIFT_STREAMLINE_REGEX
          current_package = "rubygem-swingshift-streamline-plugin"
          current_sync_dir = "swingshift/streamline"
        elsif package =~ RUBYGEM_CRANKCASE_MONGO_REGEX
          current_package = "rubygem-crankcase-mongo-plugin"
          current_sync_dir = "crankcase/mongo"
        elsif package =~ RUBYGEM_UPLIFT_DYNECT_REGEX
          current_package = "rubygem-uplift-dynect-plugin"
          current_sync_dir = "uplift/dynect"
        elsif package =~ RUBYGEM_GEARCHANGER_MCOLLECTIVE_REGEX
          current_package = "rubygem-gearchanger-m-collective-plugin"
          current_sync_dir = "gearchanger/m-collective"
        elsif package =~ CARTRIDGE_REGEX
          dir_name = $1['cartridge-'.length..-1]
          current_package = "rhc-cartridge-#{dir_name}"
          current_sync_dir = "cartridges/#{dir_name}"
        elsif package =~ RHC_REGEX
          dir_name = $1
          current_package = "rhc-#{dir_name}"
          current_sync_dir = dir_name
        elsif package =~ DRUPAL_REGEX
          dir_name $1
          current_package = "drupal6-openshift-#{dir_name}"
          current_sync_dir = dir_name
        elsif package =~ /---------------------/
          if current_package
            update_sync_history(current_package, current_package_contents, current_sync_dir, sync_dirs)
            current_package_contents = ''
            current_package = nil
            current_sync_dir = nil
          end
        end
        current_package_contents += package if current_package
      end
      update_sync_history(current_package, current_package_contents, current_sync_dir, sync_dirs) if current_package
      current_package_contents = ''
      current_package = nil
      current_sync_dir = nil
      sync_dirs.compact! 
      client_path = nil
      if File.exists?('../os-client-tools-working/express')
        client_path = '../os-client-tools-working/express'
        packages = `cd #{client_path} && tito report --untagged-commits`
        packages.split("\n").collect do |package|
          if package =~ /^rhc-[0-9]/
            current_package = 'rhc'
            current_sync_dir = client_path
          end
          current_package_contents += package if current_sync_dir
        end
        update_sync_history(current_package, current_package_contents, current_sync_dir, sync_dirs) if current_package
        sync_dirs.compact!
      end
      sync_dirs
    end
    
    def update_sync_history(current_package, current_package_contents, current_sync_dir, sync_dirs)
      current_package_file = "/tmp/devenv/sync/#{current_package}"
      previous_package_contents = nil
      if File.exists? current_package_file
        previous_package_contents = `cat #{current_package_file}`.chomp
      end
      unless previous_package_contents == current_package_contents
      sync_dirs << [current_package, current_sync_dir]
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
  end
end
