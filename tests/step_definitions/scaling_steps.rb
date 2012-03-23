require 'rubygems'
require 'uri'
require 'fileutils'

include AppHelper

When /^a scaled (.+) application is created$/ do |app_type|
  # Create our app via the curl api:
  puts "curl -k -H 'Accept: application/xml' --user 'mmcgrath@redhat.com:woot' https://localhost/broker/rest/domains/mmcgrath3218/applications -X POST -d name=hatest -d cartridge=php-5.3 -d scale=true"
end
