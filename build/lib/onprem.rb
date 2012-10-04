# This is intended to be used from the "onprem" script in the dir above
# But defining this separately allows "instrumentation" ;-)
#
######################################################################
#
# Global definitions
#
# other useful TYPEs m1.large m1.medium m1.small c1.medium etc
# t1.micro will not really support a broker install and configure
TYPE = "c1.medium"  # default size of instance to use with the AMI

# the base AMI is assumed to have repos defined and build dependencies
# installed, everything needed to bootstrap, but no devops RPMs installed
DEVOPS_BASE_WILDCARD = "devops_base_*"
# the node AMI is assumed to be the base plus all devops RPMs installed
# except for openshift-origin-{broker,node} (until these are remedied)
DEVOPS_NODE_WILDCARD = "devops_node_*"
#DEVOPS_AMI_WILDCARDS = {
#                        DEVOPS_BASE_WILDCARD => {:keep => 1, :regex => /(devops-base)-(\d+)/},
#                        DEVOPS_NODE_WILDCARD => {:keep => 1, :regex => /(devops-node)-(\d+)/},
#}

# not sure we need this yet
VERIFIER_REGEXS = {
                   /^(devops)_(\d+)$/ => {},
                   /^(devops_verifier)_(\d+)$/ => {},
                   /^(devops-base)_(\d+)$/ => {},
                   /^(broker_check)_(\d+)$/ => {},
                   /^(node_check)_(\d+)$/ => {},
}

# accepts multiple typos of "terminate" - this should be shared, no?
TERMINATE_REGEX = /terminate|teminate|termiante|terminatr|terninate/
# where to find the key to ssh to the instance
RSA = File.expand_path("~/.ssh/libra.pem")
KEY_PAIR = "libra"
CAN_SSH_TIMEOUT=90


# need these due to hardwired inherited code
SAUCE_USER = ""
SAUCE_SECRET = ""
ZONE = 'us-east-1'
$amz_options = {:key_name => KEY_PAIR, :instance_type => TYPE}
# not sure what we'll do with this yet
VERIFIED_TAG = "devops-qe-ready"


######################################################################
#
# Now pull in dependencies...

DEVTOOLS_REPO = File.join(File.dirname(__FILE__), '..', '..', '..', 'origin-dev-tools')
unless File.exists? DEVTOOLS_REPO
  puts "You need to check out origin-dev-tools next to li"
  exit 1
end

require 'rubygems'
require 'thor'
require 'fileutils'
require File.join(DEVTOOLS_REPO, 'build', 'lib', 'openshift')
require 'pp'
require 'yaml'
require File.join(DEVTOOLS_REPO, 'build', 'builder')

include FileUtils

######################################################################
#
# Define the options available for the onprem builder

module DevOps
  class BuilderPlugin < StickShift::Builder
    include OpenShift::BuilderHelper

    desc "launch TAG", "Launches and configures the latest devops instance, tagging with TAG"
    method_option :verbose, :type => :boolean, :desc => "Enable verbose logging"
    method_option :base, :type => :boolean, :desc => "Just the base image, no packages or config"
    method_option :node, :type => :boolean, :desc => "Just the node packages, and no config"
    method_option :no_conf, :type => :boolean, :desc => "Just the packages and no config"
    method_option :no_update, :type => :boolean, :desc => "Don't yum update after launch"
    method_option :image_name, :required => false, :desc => "AMI ID or DEVENV name to launch"
    method_option :ssh_config_verifier, :type => :boolean, :desc => "Set as verifier in .ssh/config"
    method_option :instance_type, :required => false, :desc => "Amazon machine type override (default '#{TYPE}')"
    method_option :region, :required => false, :desc => "Amazon region override"
    def launch(tag)
        super #just needed to define the method to override options
    end


    desc "sanity_check NAME", "validates instance can find openshift-origin-broker RPM"
    method_option :tag, :type => :boolean, :desc => "look for NAME as an Amazon tag"
    method_option :region, :required => false, :desc => "Amazon region override"
    def sanity_check(name)
      @@log.level = Logger::ERROR  #hush
      validate_instance(get_host_by_name_or_tag(name, options))
    end

    desc "sync NAME", "Synchronize a local git repo to a remote OnPrem instance.  NAME should be ssh resolvable."
    method_option :tag, :type => :boolean, :desc => "Look for NAME as an Amazon tag instead"
    method_option :devbroker, :type => :boolean, :desc => "Use rake devbroker for the remote build (default)"
    method_option :li_build, :type => :boolean, :desc => "(TODO) Use onprem update remotely to build"
    method_option :skip_build, :type => :boolean, :desc => "Just sync repos over, don't build"
    method_option :rpm, :required => false, :desc => "(TODO) Use onprem update remotely to build and install only comma-separated list of RPMs"
    method_option :verbose, :type => :boolean, :desc => "Enable verbose logging"
    method_option :region, :required => false, :desc => "Amazon region override (default #{ZONE})"
    def sync(name)
      # pwd should look like "li" or git clones will fail
      unless Dir.pwd =~ /\bli\b[^\/]*$/
        puts "Please run this command at the top level inside li"
        puts "e.g. cd ~/li; build/onprem sync ..."
        exit 1
      end
      super
      # see sync_impl below for details
    end

    # override those that are inherited but not ready
    desc "update", "TODO: local build from -working repos"
    def update
      puts "TODO: update not yet implemented"
    end
    desc "build NAME BUILD_NUM", "TODO"
    method_option :tag, :type => :boolean, :desc => "NAME is an Amazon tag"
    def build(name, num)
    end
    desc "install_local_client", "TODO"
    def install_local_client
    end
    desc "test TAG", "TODO"
    def test(tag)
    end

    # also expect to inherit from lib/builder:
    #  terminate

    ######################################################################
    #
    # Supporting methods go here

    no_tasks do
      # override how this is chosen for devenv launch
      def choose_filter_for_launch_ami(options)
        return options.base? ? DEVOPS_BASE_WILDCARD : DEVOPS_NODE_WILDCARD
      end

      # launch calls this; not needed yet
      def update_facts_impl(hostname)
      end

      # launch also calls this to perform some kind of validation of instance state
      def validate_instance(hostname, num_tries=2)
        # here we will check that it has access to the yum repos
        puts "Validating instance..."

        validation_output = ssh(hostname, 'yum info openshift-origin-broker --cacheonly', 30)
        if validation_output =~ /Name\s*:\s*openshift-origin-broker/
          puts "Instance is valid."
        else
          puts "ERROR - instance is not valid"
          puts "Node Acceptance Output:"
          puts validation_output
          exit 1
        end
      end

      # launch calls this after the instance is created and "stabilized"
      def post_launch_setup(hostname)
        unless options.no_update?
          puts "Updating instance RPMs..."
          output, rc = ssh(hostname, 'yum update -y', 300, true)
          if rc > 0
            puts "update on launch failed. output:\n#{output}"
            exit 1
          end
        end

        output, rc =
        if options.base?  #nothing more to do, just want the plain AMI
          ["", 0]
        elsif options.node? # install remaining node pkgs, no conf
          puts "Installing final node RPMs..."
          ssh(hostname, 'yum install -y openshift-origin-node', 300, true)
        elsif options.no_conf? # install node/broker pkgs, no conf
          puts "Installing final broker/node RPMs..."
          ssh(hostname, 'yum install -y openshift-origin-{node,broker}', 300, true)
        else # in the "normal" case, we want to install and configure a broker/node
          puts "Installing and configuring broker..."
          ssh(hostname, <<-SHELL, 600, true)
            yum install -y openshift-origin-node openshift-origin-broker
            ss-setup-broker
          SHELL
        end
        if rc > 0
          puts "Launch post-setup failed. output:\n#{output}"
          exit 1
        end
        puts "Launch post-setup complete."
      end

      # called from sync to do the real work
      def sync_impl(name, options)
        hostname = get_host_by_name_or_tag(name, options)

        # clone the necessary git repos from our local source
        #
        ssh_user, remote_dir = options.li_build? ? %w(root /root) : %w(build /home/build)
        clone_commands, working_dirs = sync_available_sibling_repos(hostname, remote_dir, ssh_user)
        if options.li_build?
          # we need the li repo there in order to run the "onprem" script from li
          sync_repo('li', hostname, remote_dir, ssh_user, options.verbose?)
          clone_commands += "git clone li li-working; "
          working_dirs += "li-working "
        end

        # run a remote command to copy repos and build
        output, exit_code =
        if options.skip_build?
          puts "Repos synced, skipping build."
          puts "Look in #{remote_dir} for #{working_dirs}."
          ssh(hostname, sync_shell_cmd(working_dirs, clone_commands, <<-"SHELL"), 900, true)
            exit 0
            SHELL
        elsif options.li_build?
          puts "Performing remote onprem update...."
          ssh(hostname, sync_shell_cmd(working_dirs, clone_commands, <<-"SHELL"), 900, true)
            pushd li-working > /dev/null
              build/onprem update #{options.verbose? ? '--verbose' : ''} 2>&1
            popd > /dev/null
            SHELL
        else # devbroker build
          puts "Performing remote rake devbroker...."
          ssh(hostname, sync_shell_cmd(working_dirs, clone_commands, <<-"SHELL"), 900, true)
            pushd crankcase-working/build > /dev/null
              rake build_setup 2>&1 # may be a no-op
              rake devbroker 2>&1
            popd > /dev/null
            SHELL
        end

        if exit_code != 0
          puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
          puts "Build failed!  Exiting."
          puts output
          puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
          exit 1
        end
        puts "Done"

      end

      def sync_shell_cmd(working_dirs, clone_commands, build_cmd)
        return <<-"SHELL"
          ##################
          # Start shell code

          set -e
          rm -rf #{working_dirs}
          #{clone_commands}

          #{build_cmd}

          rm -rf #{working_dirs}

          # End shell code
          ################
          SHELL
      end

    end # no_tasks end
  end # class end
end # module end

