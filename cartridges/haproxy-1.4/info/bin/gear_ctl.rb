#!/usr/bin/env ruby
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

  -t|--type  type            Type of app to create (#{type_keys}) (required)
  -d|--debug                 Print Debug info
  -h|--help                  Show Usage info
  -r|--remove                Remove a gear
  -a|--add                   Add a gear
  --config  path             Path of alternate config file
  --timeout #                Timeout, in seconds, for connection

USAGE
exit 255
end

begin
    opts = GetoptLong.new(
        ["--debug", "-d", GetoptLong::NO_ARGUMENT],
        ["--help",  "-h", GetoptLong::NO_ARGUMENT],
        ["--remove",  "-r", GetoptLong::NO_ARGUMENT],
        ["--add",  "-a", GetoptLong::NO_ARGUMENT],
        ["--type",  "-t", GetoptLong::OPTIONAL_ARGUMENT],
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

@libra_server='localhost'
@password = ' '
@rhlogin='mmcgrath@redhat.com'
@type='php-5.3'

def add_gear()
    user_info = RHC::get_user_info(@libra_server, @rhlogin, @password, @http, true)
    #p user_info

    local_filename="#{ENV['OPENSHIFT_APP_DIR']}/conf/haproxy.cfg"
    haproxy_conf = File.open(local_filename).readlines
    last_app_short = haproxy_conf[-1].split[1].split('-')[0]
    if last_app_short == 'filler' # This matches the filler default in the haproxy config
        app_num=0
    else
        app_num=(/\d+/).match(last_app_short)[0].to_i
    end
    new_app_num=app_num + 1
    new_app_name = "php#{new_app_num}"
    puts "creating #{new_app_name}"
   
    main_app = RHC::create_app(@libra_server, @http, user_info, new_app_name, @type, @rhlogin, @password, '/dev/null', false, true, false)
    #p main_app
    
    ctl_out = RHC::ctl_app(@libra_server, @http, new_app_name, @rhlogin, @password, 'expose-port', false, @type, false)
    new_gear=ctl_out["messages"].split()[2]
    gear_name=new_gear.split('.')[0]
    
    add_string="    server #{gear_name} #{new_gear} check fall 2 rise 3 inter 2000\n"
    
    File.open(local_filename, 'a') {|f| f.write(add_string) }
end

def remove_gear()
    local_filename="#{ENV['OPENSHIFT_APP_DIR']}/conf/haproxy.cfg"
    haproxy_conf = File.open(local_filename).readlines
    last_app = haproxy_conf[-1].split[1]
    last_app_short = last_app.split('-')[0]
    app = last_app_short
    haproxy_conf.delete_if{|line| line.include?(" #{last_app} ")}
    puts "removing #{last_app}"
    ctl_out = RHC::ctl_app(@libra_server, @http, app, @rhlogin, @password, 'deconfigure', false, @type, false)
    File.open(local_filename, 'w') {|fp| fp.write(haproxy_conf) }
end


if opt['remove']
    remove_gear
    exit 0
elsif opt['add']
    add_gear
    exit 0
end
