#
# Global definitions
#
AMI = "ami-3c39c755"
TYPE = "m1.large"
KEY_PAIR = "libra"
ZONE = 'us-east-1d'
OPTIONS = {:key_name => KEY_PAIR, :instance_type => TYPE, :availability_zone => ZONE}
VERSION_REGEX = /rhc-\d+\.\d+\.?\d*-\d+/
AMI_REGEX = /devenv-\d+\.\d+/
BUILD_REGEX = /^builder-rhc-\d+\.\d+/
TERMINATE_REGEX = /terminate/
PREFIX = ENV['LIBRA_DEV'] ? ENV['LIBRA_DEV'] + "-" : ""
VERIFIER_REGEX = /^#{PREFIX}verifier-rhc-\d+\.\d+/
VERIFIED_TAG = "qe-ready"
BREW_LI = "https://brewweb.devel.redhat.com/packageinfo?packageID=31345"
GIT_REPO_PUPPET = "ssh://puppet1.ops.rhcloud.com/srv/git/puppet.git"
CONTENT_TREE = {'puppet' => '/etc/puppet'}
RSA = File.expand_path("~/.ssh/libra.pem")
SSH = "ssh 2> /dev/null -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PasswordAuthentication=no -i " + RSA
SCP = "scp 2> /dev/null -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PasswordAuthentication=no -i " + RSA
