module OpenShift
  module Tito
    def get_build_dirs
      # Figure out what needs to be built
      packages = `tito report --untagged-commits`
      build_dirs = packages.split("\n").collect do |package|
        if package =~ /^rhc-devenv-0/
          "misc/devenv"
        elsif package =~ /^rubygem-cloud-sdk-0/
          "cloud-sdk"
        elsif package =~ /^rhc-(cartridge-.*)-0/
          "cartridges/" + $1['cartridge-'.length..-1]
        elsif package =~ /^rhc-(.*)-0/
          $1
        end
      end.compact
      client_path = nil
      if File.exists?('../os-client-tools/express')
        client_path = '../os-client-tools/express'
      elsif File.exists?('../os-client-tools-working/express')
        client_path = '../os-client-tools-working/express'
      end
      if client_path
        packages = `cd #{client_path} && tito report --untagged-commits`
        build_dirs += packages.split("\n").collect do |package|
          if package =~ /^rhc-[0-9]/
            client_path
          end
        end.compact
      end
      build_dirs
    end
  end
end
