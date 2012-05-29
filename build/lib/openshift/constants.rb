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
DEVENV_WILDCARD = "devenv_*"
DEVENV_STAGE_WILDCARD = "devenv-stage_*"
DEVENV_CLEAN_WILDCARD = "devenv-clean_*"
DEVENV_STAGE_CLEAN_WILDCARD = "devenv-stage-clean_*"
DEVENV_BASE_WILDCARD = "devenv-base_*"
DEVENV_STAGE_BASE_WILDCARD = "devenv-stage-base_*"
DEVENV_AMI_WILDCARDS = {DEVENV_WILDCARD => {:keep => 2, :regex => /devenv_(\d*)/}, 
                        DEVENV_STAGE_WILDCARD => {:keep => 8, :regex => /devenv-stage_(\d*)/},
                        DEVENV_CLEAN_WILDCARD => {:keep => 1, :regex => /devenv-clean_(\d*)/},
                        DEVENV_STAGE_CLEAN_WILDCARD => {:keep => 1, :regex => /devenv-stage-clean_(\d*)/},
                        DEVENV_BASE_WILDCARD => {:keep => 1, :regex => /devenv-base_(\d*)/},
                        DEVENV_STAGE_BASE_WILDCARD => {:keep => 1, :regex => /devenv-stage-base_(\d*)/}}
VERIFIER_REGEXS = {/^(devenv)_(\d+)$/ => {},
                   /^(devenv_verifier)_(\d+)$/ => {}, 
                   /^(devenv-stage)_(\d+)$/ => {}, 
                   /^(devenv-stage_verifier)_(\d+)$/ => {},
                   /^(devenv-base)_(\d+)$/ => {}, 
                   /^(devenv-stage-base)_(\d+)$/ => {},
                   /^(libra_check)_(\d+)$/ => {},
                   /^(pull_request)_(\d+)$/ => {:multiple => true}, 
                   /^(broker_check)_(\d+)$/ => {}, 
                   /^(node_check)_(\d+)$/ => {}, 
                   /^(libra_web)_(\d+)$/ => {}, 
                   /^(libra_coverage)_(\d+)$/ => {}}
QE_VERIFIER_REGEXS = [/^pdevenv_.*$/]
TERMINATE_REGEX = /terminate|teminate|termiante/
VERIFIED_TAG = "qe-ready"
RSA = File.expand_path("~/.ssh/libra.pem")
SAUCE_USER = "openshift_ci"
SAUCE_SECRET = "3d67e770-ce7d-482a-8c7f-07aec039d564"
SAUCE_OS = "Windows 2008"
SAUCE_BROWSER = "firefox"
SAUCE_BROWSER_VERSION = "7"
CAN_SSH_TIMEOUT=90

$amz_options = {:key_name => KEY_PAIR, :instance_type => TYPE}
