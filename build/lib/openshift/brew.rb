require 'build/lib/openshift/tito.rb'# FIXME - I think this is wrong 

module OpenShift
  module Brew

    include OpenShift::Tito

    # Public: Obtain the set of packages needing to be taggedin to stage
    # 
    # source  - The source brew tag to lookup (example: libra-rhel-6.2-candidate)
    # target  - The target brew tag to lookup (example: libra-rhel-6.2-stage)
    # date    - Date since last stage: remove brew obsoletes (ex: 2012-04-15)
    #
    # Examples:
    #   get_packages_to_tag("libra-rhel-6.2-candidate", "libra-rhel-6.2-stage", "2012-04-15")
    #   # => ["rhc-0.91.12-1.el6_2", "rhc-broker-0.91.18-1.el6_2"]
    #
    # Returns an array of brew package names
    def get_packages_to_tag(source, target, date)
  
      stage_candidates = []   # store candidates from brew query
      need_stage_tags = []    # final set of packages that need tagging
      our_pkgs = []           # our packages w/ full version from brew query
      our_pkgs_names = get_packages # <-- from Tito
      

      # FIXME:  I'm open to suggestion about the awk, I just couldn't think of a
      #         more clean implementation to get only tagged lines and the pkg
      source = `brew -q latest-pkg #{[source]} --all \
                                              | awk '{print $1}'`.split("\n")
      target = `brew -q latest-pkg #{[target]} --all \
                                              | awk '{print $1}'`.split("\n")

      # Find which packages are new since last stage
      source.each do | pkg |
        stage_candidates.push( pkg ) unless target.include? pkg
      end

      # Find which packages belong to us
      stage_candidates.each do | stg_candidate_pkg |
        our_pkgs_names.each do | pkg, paths |
          if stg_candidate_pkg =~ /#{pkg}-\d+\.\d+.*/
            our_pkgs.push(stg_candidate_pkg)
          end
        end
      end

      # Now put it all together (remove our_pkgs and obsoletes)
      stage_candidates.each do | pkg |

        # Special thanks to markllama, tdawson, and kwoodson for helping on this
        # little nugget - strips off the Version-Release from pkg build
        pkg_base_name = pkg.match(/(.*)(-[^-]+-[^-]+$)/)[1]

        # FIXME - This takes forever to run because of the brew query for each
        #         candidate package. Not sure of a better way to fix just yet.
        brew_recent_activity = `brew list-history --tag=#{[source]} \
                                --package=#{pkg_base_name} \
                                --after=#{[date]}` unless our_pkgs.include? pkg

        # Add to need_stage_tags unless it is one of ours, brew knows nothing
        # about it and make sure there is recent activity in brew for the pkg
        need_stage_tags.push( pkg ) \
                unless our_pkgs.include? pkg \
                      or ( ! brew_recent_activity.match(/GenericError/) \
                      and brew_recent_activity.length > 1 )
      end
      


      need_stage_tags
    end
  
  end
end
