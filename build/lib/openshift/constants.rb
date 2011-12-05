#
# Global definitions
#
AMI = {"us-east-1" =>"ami-7dea2614", "eu-west-1" => "ami-33caf847", "us-west-1" => "ami-4b7a260e", "ap-northeast-1" => "ami-66942067", "ap-southeast-1" => "ami-60017b32"}
TYPE = "m1.large"
KEY_PAIR = "libra"
ZONE = 'us-east-1d'
DEVENV_WILDCARD = "devenv_*"
DEVENV_STAGE_WILDCARD = "devenv-stage_*"
DEVENV_CLEAN_WILDCARD = "devenv-clean_*"
TERMINATE_REGEX = /terminate/
VERIFIED_TAG = "qe-ready"
RSA = File.expand_path("~/.ssh/libra.pem")
SAUCE_USER = "openshift_ci"
SAUCE_SECRET = "3d67e770-ce7d-482a-8c7f-07aec039d564"
SAUCE_OS = "Windows 2008"
SAUCE_BROWSER = "firefox"
SAUCE_BROWSER_VERSION = "7"
CAN_SSH_TIMEOUT=45

$amz_options = {:key_name => KEY_PAIR, :instance_type => TYPE}
