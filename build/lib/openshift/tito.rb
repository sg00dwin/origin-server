module OpenShift
  module Tito
    def get_build_dirs
      # Figure out what needs to be built
      packages = `tito report --untagged-commits`
      build_dirs = packages.split("\n").collect do |package|
        if package =~ /^rhc-devenv-0/
          "misc/devenv"
        elsif package =~ /^rhc-(cartridge-.*)-0/
          "cartridges/" + $1['cartridge-'.length..-1]
        elsif package =~ /^rhc-[0-9]/
          "client"
        elsif package =~ /^rhc-(.*)-0/
          $1
        end
      end.compact
      puts "Changes detected in the following directories: #{build_dirs.pretty_inspect}"
    end
  end
end
