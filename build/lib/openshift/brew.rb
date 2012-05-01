module OpenShift
  module Brew


    # Public: Obtain the set of packages needing to be taggedin to stage
    # 
    # source  - The source brew tag to lookup (example: libra-rhel-6.2-candidate)
    # target  - The target brew tag to lookup (example: libra-rhel-6.2-stage)
    # date    - How far back to look - last stage day (example: 2012-04-15)
    #
    # Examples:
    #   get_packages_to_tag("libra-rhel-6.2-candidate", "libra-rhel-6.2-stage", "2012-04-15")
    #   # => ["rhc-0.91.12-1.el6_2", "rhc-broker-0.91.18-1.el6_2"]
    #
    # Returns an array of brew package names
    def get_packages_to_tag(source, target, date)
  
      stage_candidates = []

      # FIXME:  I'm open to suggestion about the awk, I just couldn't think of a
      #         more clean implementation to get only tagged lines and the pkg
      source = `brew list-history --tag #{[source]} \
                    --after=#{[date]} | awk '/ tagged/{print $6}'`.split("\n")
      target = `brew list-history --tag #{[target]} \
                    --after=#{[date]} | awk '/ tagged/{print $6}'`.split("\n")
      
      source.each do | pkg |
        stage_candidates.push( pkg ) unless target.include? pkg
      end


      stage_candidates
    end
end
