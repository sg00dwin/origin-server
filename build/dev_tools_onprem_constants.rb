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
VERIFIED_TAG = "qe-ready"