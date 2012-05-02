module OpenShift
  module Brew


    # Public: Obtain the set of packages needing to be taggedin to stage
    # 
    # source  - The source brew tag to lookup (example: libra-rhel-6.2-candidate)
    # target  - The target brew tag to lookup (example: libra-rhel-6.2-stage)
    #
    # Examples:
    #   get_packages_to_tag("libra-rhel-6.2-candidate", "libra-rhel-6.2-stage")
    #   # => ["rhc-0.91.12-1.el6_2", "rhc-broker-0.91.18-1.el6_2"]
    #
    # Returns an array of brew package names
    def get_packages_to_tag(source, target)
  
      stage_candidates = []

      # FIXME:  I'm open to suggestion about the awk, I just couldn't think of a
      #         more clean implementation to get only tagged lines and the pkg
      source = `brew -q latest-pkg #{[source]} --all \
                                              | awk '{print $1}'`.split("\n")
      target = `brew -q latest-pkg #{[target]} --all \
                                              | awk '{print $1}'`.split("\n")

      source.each do | pkg |
        stage_candidates.push( pkg ) unless target.include? pkg
      end
      stage_candidates
    end
  
  end
end
