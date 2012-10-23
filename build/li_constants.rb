#
# Global definitions
#
# RHEL official images
#AMI = {"us-east-1" =>"ami-4509c12c", "eu-west-1" => "ami-69360a1d", "us-west-1" => "ami-8b95cace", "ap-northeast-1" => "ami-aeb601af", "ap-southeast-1" => "ami-9e1d58cc", "us-west-2" => "ami-ec810cdc"}
#
# Blentz OpenShift images
AMI = {"us-east-1" =>"ami-938c5dfa"}
TYPE = "m1.large"
KEY_PAIR = "libra"
ZONE = 'us-east-1d'


DEVENV_NAME = 'devenv'

IMAGES = {DEVENV_NAME => {:base => true, :stage => true},
          'oso-fedora' => {:base => true, :stage => false}}

DEVENV_AMI_WILDCARDS = {}
IMAGES.each do |image, opts|
  keep = opts[:keep] ? opts[:keep] : 2
  DEVENV_AMI_WILDCARDS["#{image}_*"] = {:keep => keep, :regex => /^(#{image})_(\d+)/}
  if opts[:base]
    DEVENV_AMI_WILDCARDS["#{image}-base_*"] = {:keep => 2, :regex => /^(#{image}-base)_(\d+)/}
  end
  if opts[:stage]
    DEVENV_AMI_WILDCARDS["#{image}-stage-base_*"] = {:keep => 8, :regex => /^(#{image}-stage-base)_(\d+)/}
  end
end

DEVENV_AMI_WILDCARDS["fork_ami_*"] = {:keep => 50, :keep_per_sub_group => 1, :regex => /(fork_ami_.*)_(\d+)/}

VERIFIER_REGEXS = {/^(devenv).*_(\d+)$/ => {:multiple => true},
                   /^(oso-fedora).*_(\d+)$/ => {:multiple => true},
                   /^((test|merge)_pull_requests).*_(\d+)$/ => {:multiple => true, :max_run_time => (60*60*2)},
                   /^(fork_ami)_.*_(\d+)$/ => {:multiple => true}}
TERMINATE_REGEX = /terminate|teminate|termiante|terminatr|terninate/
VERIFIED_TAG = "qe-ready"

# Specify the source location of the SSH key
# This will be used if the key is not found at the location specified by "RSA"
RSA = File.expand_path("~/.ssh/devenv.pem")
RSA_SOURCE = File.expand_path("../../misc/libra.pem", File.expand_path(__FILE__))

SAUCE_USER = "openshift_ci"
SAUCE_SECRET = "3d67e770-ce7d-482a-8c7f-07aec039d564"
SAUCE_OS = "Windows 2008"
SAUCE_BROWSER = "firefox"
SAUCE_BROWSER_VERSION = "7"
CAN_SSH_TIMEOUT=90

JENKINS_HOME_DIR = '/var/lib/jenkins'

SIBLING_REPOS = {'origin-server' => ['../origin-server-working', '../origin-server-fork', '../origin-server', JENKINS_HOME_DIR + '/jobs/origin-server/workspace'],
                 'rhc' => ['../rhc-working', '../rhc-fork', '../rhc', JENKINS_HOME_DIR + '/jobs/rhc/workspace'],
                 'li' => ["../#{File.basename(FileUtils.pwd)}"],
                 'origin-dev-tools' => ['../origin-dev-tools']}
SIBLING_REPOS_GIT_URL = {'origin-server' => 'https://github.com/openshift/origin-server.git',
                        'rhc' => 'https://github.com/openshift/rhc.git',
                        'li' => 'git@github.com:openshift/li.git',
                        'origin-dev-tools' => 'git@github.com:openshift/origin-dev-tools.git'}

CUCUMBER_OPTIONS = '--strict -f progress -f junit --out /tmp/rhc/cucumber_results'
IGNORE_PACKAGES = ['bind-local', 'rubygem-rhc', 'openshift-origin-broker', 'rubygem-openshift-origin-auth-mongo', 'rubygem-openshift-origin-dns-bind', 'openshift-origin', 'rubygem-openshift-origin-auth-kerberos', 'cartridge-postgresql-9.1', 'cartridge-php-5.4']
$amz_options = {:key_name => KEY_PAIR, :instance_type => TYPE}
