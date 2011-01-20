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
require "json"
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
# Check for local var in ~/.li use it, else use /etc/libra/client.conf
#
def get_var(var)
    @local_config.get_value(var) ? @local_config.get_value(var) : @global_config.get_value(var)
end

#
# print help
#
def p_usage
    puts <<USAGE

Usage: create_customer
Create a new libra user.

  -u|--user   username    Libra username (alphanumeric) (required)
  -e|--email  email       Email address (required)
  -d|--debug              Print Debug info
  -h|--help               Show Usage info

USAGE
exit 255
end

def validate_email(email)
    if email =~ /([^@]+)@([a-zA-Z0-9\.])+\.([a-zA-Z]{2,3})/
        if $1 =~ /[^a-zA-Z0-9\.]/
            return false
        else
            return true
        end
    else
        return false
    end
end

opts = GetoptLong.new(
    ["--debug", "-d", GetoptLong::NO_ARGUMENT],
    ["--help",  "-h", GetoptLong::NO_ARGUMENT],
    ["--user",  "-u", GetoptLong::REQUIRED_ARGUMENT],
    ["--email", "-e", GetoptLong::REQUIRED_ARGUMENT]
)

# Pull in configs from files
li_server = get_var('li_server')
debug = get_var('debug')

libra_kfile = "#{ENV['HOME']}/.ssh/libra_id_rsa"
libra_kpfile = "#{ENV['HOME']}/.ssh/libra_id_rsa.pub"

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

if opt["email"]
    if !validate_email(opt["email"])
        puts "email contains invalid characters!"
        p_usage
    end
else
    puts "Libra email address is required"
end

if !opt["email"] || !opt["user"]
    p_usage
end

#
# Check to see if a libra_id_rsa key exists, if not create it.
#

if File.readable?(libra_kfile)
    puts "Libra key found at #{libra_kfile}.  Reusing..."
else
    puts "Generating libra ssh key to #{libra_kfile}"
    # Use system for interaction
    system("ssh-keygen -t rsa -f #{libra_kfile}")
end

ssh_key = File.open(libra_kpfile).gets.chomp.split(' ')[1]

puts "Contacting http://#{li_server}"
json_data = JSON.generate(
                {'username' => opt['user'],
                'email' => opt['email'],
                'ssh' => ssh_key})
puts "DEBUG: Json string: #{json_data}" if debug
response = Net::HTTP.post_form(URI.parse("http://#{li_server}/php/create_customer.php"),
                           {'json_data' => json_data,})
puts "DEBUG:" if debug
p response if debug
if response.code == '200'
    if debug
        puts "HTTP response from server is #{response.body}"
    end
    puts "Creation successful (probably)."
    puts
    puts "You may now create an application"
    puts
    exit 0
else
    puts "Problem with server. Response code was #{response.code}"
    puts "HTTP response from server is #{response.body}"
    exit 255
end
