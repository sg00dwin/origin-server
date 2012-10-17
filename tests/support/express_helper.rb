# Include the setup helper constants

require File.dirname(__FILE__) + "/../../controller/test/cucumber/support/00_setup_helper.rb"

#
# Override any express specific settings now
#

# Override the dns helper module
$dns_helper_module = File.dirname(__FILE__) + "/dns_helper"

# Use the domain from the rails application configuration
$domain = "dev.rhcloud.com"

# user registration flag and script format, if any
$registration_required = false
$user_register_script_format = nil

# mcollective service and selinux context
$gear_update_plugin_service = "mcollective"
$selinux_user = "unconfined_u"
$selinux_role = "system_r"
$selinux_type = "openshift_initrc_t"

# Submodule repo directory for testing submodule addition test case
$submodule_repo_dir = "/root/submodule_test_repo"

#
# require the rest of the helper modules now
#

Dir.glob(File.dirname(__FILE__) + "/../../controller/test/cucumber/support/*").each { |helper|
  require helper unless ["00_setup_helper.rb", "dns_helper.rb"].include? File.basename(helper)
}



module ExpressHelper

end
World(ExpressHelper)
