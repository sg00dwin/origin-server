require '/var/www/stickshift/broker/config/environment'

Dir.glob(File.dirname(__FILE__) + "/../../stickshift/controller/test/cucumber/support/*").each { |helper|
  # exclude any stickshift specific helpers or those that are being overridden in express
  require helper unless [].include? File.basename(helper)
}

#
# Override any express specific settings here
#


# user registration flag and script
$registration_required = false
$user_register_script = nil


# mcollective service and selinux context
$gear_update_plugin_service = "mcollective"
$selinux_user = "unconfined_u"
$selinux_role = "system_r"
$selinux_type = "libra_initrc_t"



module ExpressHelper

end
World(ExpressHelper)