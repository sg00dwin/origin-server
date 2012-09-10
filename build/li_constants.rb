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
OSO_FEDORA_WILDCARD = "oso-fedora_*"
OSO_FEDORA_BASE_WILDCARD = "oso-fedora-base_*"
FORK_AMI_WILDCARD = "fork_ami_*"
DEVENV_AMI_WILDCARDS = {DEVENV_WILDCARD => {:keep => 2, :regex => /(devenv)_(\d+)/}, 
                        DEVENV_STAGE_WILDCARD => {:keep => 8, :regex => /(devenv-stage)_(\d+)/},
                        DEVENV_CLEAN_WILDCARD => {:keep => 1, :regex => /(devenv-clean)_(\d+)/},
                        DEVENV_STAGE_CLEAN_WILDCARD => {:keep => 1, :regex => /(devenv-stage-clean)_(\d+)/},
                        DEVENV_BASE_WILDCARD => {:keep => 1, :regex => /(devenv-base)_(\d+)/},
                        DEVENV_STAGE_BASE_WILDCARD => {:keep => 1, :regex => /(devenv-stage-base)_(\d+)/},
                        OSO_FEDORA_WILDCARD => {:keep => 2, :regex => /(oso-fedora)_(\d+)/},
                        OSO_FEDORA_BASE_WILDCARD => {:keep => 1, :regex => /(oso-fedora-base)_(\d+)/},
                        FORK_AMI_WILDCARD => {:keep => 50, :keep_per_sub_group => 1, :regex => /(fork_ami_.*)_(\d+)/}}
VERIFIER_REGEXS = {/^(devenv)_(\d+)$/ => {:multiple => true},
                   /^(devenv_verifier)_(\d+)$/ => {}, 
                   /^(devenv-stage)_(\d+)$/ => {}, 
                   /^(devenv-stage_verifier)_(\d+)$/ => {},
                   /^(devenv-base)_(\d+)$/ => {},
                   /^(devenv-stage-base)_(\d+)$/ => {},
                   /^(oso-fedora)_(\d+)$/ => {},
                   /^(oso-fedora-base)_(\d+)$/ => {},
                   /^(libra_benchmark)_(\d+)$/ => {:max_run_time => (60*60*24)},
                   /^(broker_extended)_(\d+)$/ => {:max_run_time => (60*60*4)},
                   /^(runtime_extended)_(\d+)$/ => {:max_run_time => (60*60*4)},
                   /^(site_extended)_(\d+)$/ => {:max_run_time => (60*60*4)},
                   /^(rhc_extended)_(\d+)$/ => {:max_run_time => (60*60*4)},
                   /^(test_pull_requests)_(\d+)$/ => {:multiple => true},
                   /^(test_pull_requests_stage)_(\d+)$/ => {:multiple => true},
                   /^(merge_pull_request)_(\d+)$/ => {},
                   /^(merge_pull_request_stage)_(\d+)$/ => {},
                   /(fork_ami)_.*_(\d+)$/ => {:multiple => true},
                   /^(broker_check)_(\d+)$/ => {}, 
                   /^(node_check)_(\d+)$/ => {}, 
                   /^(libra_web)_(\d+)$/ => {:max_run_time => (60*60*3)}, 
                   /^(libra_coverage)_(\d+)$/ => {:max_run_time => (60*60*1)}}
TERMINATE_REGEX = /terminate|teminate|termiante|terminatr|terninate/
VERIFIED_TAG = "qe-ready"
RSA = File.expand_path("~/.ssh/libra.pem")
SAUCE_USER = "openshift_ci"
SAUCE_SECRET = "3d67e770-ce7d-482a-8c7f-07aec039d564"
SAUCE_OS = "Windows 2008"
SAUCE_BROWSER = "firefox"
SAUCE_BROWSER_VERSION = "7"
CAN_SSH_TIMEOUT=90

$amz_options = {:key_name => KEY_PAIR, :instance_type => TYPE}
