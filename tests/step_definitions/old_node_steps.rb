# 
# 
# Steps that can be used to check applications installed on a server (node)
#
#require 'etc'

require 'openshift'
require 'resolv'
include OpenShift


When /^I create a new namespace OLD$/ do
  exit_code = run("#{$create_domain_script} -n vuvuzuzufukuns -l vuvuzuzufuku -p fakepw -d")
end

When /^I make the REST call to delete the namespace$/ do
  data = '{"rhlogin":"vuvuzuzufuku", "delete":true, "namespace":"vuvuzuzufukuns"}'
  ec = run("curl -k --key ~/.ssh/libra_id_rsa -d \"json_data=#{data}\" -d \"password=' '\" https://localhost/broker/domain")
  ec.should be == 0
end