#
# Global definitions
#
AMI = "ami-7dea2614"
TYPE = "m1.large"
KEY_PAIR = "libra"
ZONE = 'us-east-1d'
DEVENV_WILDCARD = "devenv_*"
DEVENV_STAGE_WILDCARD = "devenv-stage_*"
DEVENV_CLEAN_WILDCARD = "devenv-clean_*"
TERMINATE_REGEX = /terminate/
VERIFIED_TAG = "qe-ready"
RSA = File.expand_path("~/.ssh/libra.pem")

$amz_options = {:key_name => KEY_PAIR, :instance_type => TYPE, :availability_zone => ZONE}
