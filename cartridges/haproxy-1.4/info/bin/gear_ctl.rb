#!/usr/bin/env ruby
# Copyright 2012 Red Hat, Inc
#

require 'rubygems'
require 'rhc-common'

def p_usage
    libra_server = get_var('libra_server')
    rhlogin = get_var('default_rhlogin') ? "Default: #{get_var('default_rhlogin')}" : "required"
    type_keys = RHC::get_cartridge_listing(nil, ', ', libra_server, @http, 'standalone', false)
    puts <<USAGE

Usage: #{$0}
Create an OpenShift Express app.

  -a|--app   application     Application name  (alphanumeric - max #{RHC::APP_NAME_MAX_LENGTH} chars) (required)
  -t|--type  type            Type of app to create (#{type_keys}) (required)
  -d|--debug                 Print Debug info
  -h|--help                  Show Usage info
  --config  path             Path of alternate config file
  --timeout #                Timeout, in seconds, for connection

USAGE
exit 255
end

begin
    opts = GetoptLong.new(
        ["--debug", "-d", GetoptLong::NO_ARGUMENT],
        ["--help",  "-h", GetoptLong::NO_ARGUMENT],
        ["--app",   "-a", GetoptLong::REQUIRED_ARGUMENT],
        ["--type",  "-t", GetoptLong::REQUIRED_ARGUMENT],
        ["--timeout", GetoptLong::REQUIRED_ARGUMENT]
    )
    opt = {}
    opts.each do |o, a|
        opt[o[2..-1]] = a.to_s
    end
rescue Exception => e
  #puts e.message
  p_usage
end

libra_server='localhost'
password = ' '
rhlogin='mmcgrath@redhat.com'
action='expose-port'

user_info = RHC::get_user_info(libra_server, rhlogin, password, @http, true)
#p user_info

main_app = RHC::create_app(libra_server, @http, user_info, opt['app'], opt['type'], rhlogin, password, '/dev/null', opt['no-dns'], true, false)
#p main_app

ctl_out = RHC::ctl_app(libra_server, @http, opt['app'], rhlogin, password, action, false, opt['type'], false)
new_gear=ctl_out["messages"].split()[2]
gear_name=new_gear.split('.')[0]

add_string="    server #{gear_name} #{new_gear} check fall 2 rise 3 inter 2000\n"
puts add_string

local_filename="/var/lib/libra/a35777ade8e54a41b83ad6b8c21ed187/ha1/conf/haproxy.cfg"
File.open(local_filename, 'a') {|f| f.write(add_string) }
