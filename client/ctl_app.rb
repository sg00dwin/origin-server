#!/usr/bin/env ruby
# Copyright © 2010 Jim Jagielski All rights reserved
# Copyright © 2010 Mike McGrath All rights reserved
# Copyright © 2010 Red Hat, Inc. All rights reserved

# This copyrighted material is made available to anyone wishing to use, modify,
# copy, or redistribute it subject to the terms and conditions of the GNU
# General Public License v.2.  This program is distributed in the hope that it
# will be useful, but WITHOUT ANY WARRANTY expressed or implied, including the
# implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.  You should have
# received a copy of the GNU General Public License along with this program;
# if not, write to the Free Software Foundation, Inc., 51 Franklin Street,
# Fifth Floor, Boston, MA 02110-1301, USA. Any Red Hat trademarks that are
# incorporated in the source code or documentation are not subject to the GNU
# General Public License and may only be used or replicated with the express
# permission of Red Hat, Inc.

require "rubygems"
require "uri"
require "net/http"
require "getoptlong"
require 'resolv'
require 'json'
require 'parseconfig'

config_path = File.exists?('client.conf') ? 'client.conf' : '/etc/libra/client.conf'

unless File.exists?("#{ENV['HOME']}/.li")
    file = File.open("#{ENV['HOME']}/.li", 'w')
    file.close
end

begin
    @global_config = ParseConfig.new(config_path)
    @local_config = ParseConfig.new("#{ENV['HOME']}/.li")
rescue Errno::EACCES => e
    puts "Could not open config file: #{e.message}"
    exit 253
end

#
# Check if host exists
# 
def hostexist?(host)
    dns = Resolv::DNS.new
    resp = dns.getresources(host, Resolv::DNS::Resource::IN::A)
    return resp.any?
end

#
# Check for local var in ~/.li use it, else use /etc/libra/client.conf
#
def get_var(var)
    @local_config.get_value(var) ? @local_config.get_value(var) : @global_config.get_value(var)
end

def p_usage
    puts <<USAGE

Usage: ctl_app
Control a libra app

  -u|--user  username     Libra username    (alphanumeric) (required)
  -a|--app   application  Application name  (alphanumeric) (required)
  -t|--type  type         Type of app to create (php-5.3.2) (required)
  -c|--command command    (start|stop|restart|reload|status|destroy)
  -b|--bypass             Bypass warnings
  -d|--debug              Print Debug info
  -h|--help               Show Usage info

USAGE
exit 255
end

opts = GetoptLong.new(
    ["--debug",     "-d", GetoptLong::NO_ARGUMENT],
    ["--help",      "-h", GetoptLong::NO_ARGUMENT],
    ["--bypass",    "-b", GetoptLong::NO_ARGUMENT],
    ["--user",      "-u", GetoptLong::REQUIRED_ARGUMENT],
    ["--app",       "-a", GetoptLong::REQUIRED_ARGUMENT],
    ["--command",   "-c", GetoptLong::REQUIRED_ARGUMENT],
    ["--type",      "-t", GetoptLong::REQUIRED_ARGUMENT]
)


# Pull in configs from files
libra_domain = get_var('libra_domain')
libra_dir = get_var('libra_dir')
li_server = get_var('li_server')
debug = get_var('debug')
ssh_config = "#{ENV['HOME']}/.ssh/config"
ssh_config_d = "#{ENV['HOME']}/.ssh/"

opt = {}
opts.each do |o, a|
    opt[o[2..-1]] = a.to_s
end

if opt["help"]
    p_usage
end

if opt["debug"]
    debug = true
end

if opt["user"]
    if opt["user"] =~ /[^0-9a-zA-Z]/
        puts "username contains non-alphanumeric characters!"
        p_usage
    end
else
    puts "Libra username is required"
end

if opt["app"]
    if opt["app"] =~ /[^0-9a-zA-Z]/
        puts "application name contains non-alphanumeric characters!"
        p_usage
    end
else
    puts "Libra application name is required"
end

if opt["type"]
    if !(opt["type"] =~ /^(php-5.3.2)$/)
        puts "type must be php-5.3.2"
        p_usage
    end
else
    puts "Type is required"
    p_usage
end

unless defined? opt["command"] and opt["command"] =~ /(start|stop|restart|reload|status|destroy)/
    puts "Command is required"
    p_usage
end
if !opt["user"] || !opt["app"] || !opt["command"] || !opt["type"]
    p_usage
end


#
# Send Warning
#

if !opt["bypass"] and opt["command"] == "destroy"
    puts <<WARNING
!!!! WARNING !!!! WARNING !!!! WARNING !!!!
You are about to destroy the #{opt['app']} application.

This is NOT reversable, all remote data for this application will be removed.
WARNING

    print "Do you want to destroy this application (y/n): "
    agree = gets.chomp
    if agree != 'y'
        puts "Sorry this won't work for you, keep tabs for future updates"
        exit 5
    end
end
puts ""
puts "Remember: this is pre-alpha destructionware.  Let #libra know of any bugs you find"
puts ""

#
# Create remote application space
#

puts "Creating remote application space: " + opt['app']

json_data = JSON.generate(
               {:cartridge => "#{opt['type']}",
                :action => opt['command'],
                :app_name => "#{opt['app']}",
                :username => "#{opt['user']}"})

puts "Contacting server http://#{li_server}"
response = Net::HTTP.post_form(URI.parse("http://#{li_server}/php/cartridge_do.php"),
                           { 'json_data' => json_data })

if response.code == '200'
    puts "HTTP response from server is #{response.body}" if debug
    puts "Action successful"
    if !(response.body =~ /Success/)
        puts "An error has occured: #{response.body}"
        exit 253
    end
else
    puts "Problem with server. Response code was #{response.code}"
    puts "HTTP response from server is #{response.body}"
    exit 254
end
