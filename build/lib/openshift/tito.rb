module OpenShift
  module Tito
    def get_build_dirs
      # Figure out what needs to be built
      packages = `tito report --untagged-commits`
      build_dirs = packages.split("\n").collect do |package|
        if package =~ /^rhc-devenv-\d/
          "misc/devenv"
        elsif package =~ /^rubygem-cloud-sdk-\d/
          "cloud-sdk"
        elsif package =~ /^rhc-(cartridge-[\w-]+\d\.\d)-/
          "cartridges/" + $1['cartridge-'.length..-1]
        elsif package =~ /^rhc-([\w-]+)-\d/
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
