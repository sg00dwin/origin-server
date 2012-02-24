require 'fileutils'

module OpenShift
  module Tito
    def get_build_dirs
      # Figure out what needs to be built
      packages = `tito report --untagged-commits`
      build_dirs = packages.split("\n").collect do |package|
        if package =~ /^rhc-devenv-\d+/
          "misc/devenv"
        elsif package =~ /^rubygem-cloud-sdk-([\w]+)-\d+/
          "cloud-sdk/#{$1}"
        elsif package =~ /^rhc-(cartridge-[\w-]+\d+[\.\d+]*)-\d+\.\d+\.\d+-/
          "cartridges/" + $1['cartridge-'.length..-1]
        elsif package =~ /^rhc-([\w-]+)-\d+/
          $1
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
        if package =~ /^rhc-devenv-\d+/
          puts "The devenv package has an update but isn't being installed."
        elsif package =~ /^rubygem-cloud-sdk-([\w]+)-\d+/
          component = $1
          current_package = "cloud-sdk-#{component}"
          current_sync_dir = "cloud-sdk/#{component}"
        elsif package =~ /^rhc-(cartridge-[\w-]+\d+[\.\d+]*)-\d+\.\d+\.\d+-/
          current_package = $1['cartridge-'.length..-1]
          current_sync_dir = "cartridges/#{current_package}"
        elsif package =~ /^rhc-([\w-]+)-\d+/
          current_package = $1
          current_sync_dir = current_package
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
        sync_dirs << current_sync_dir
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
