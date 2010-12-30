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

require "uri"
require "net/http"
require "getoptlong"

#
# Globals
#
li_server = 'li.mmcgrath.libra.mmcgrath.net'
debug = false

def p_usage
    puts <<USAGE

Usage: create_http
Create a new LAMP libra project.

  -u|--user  username     Libra username    (alphanumeric) (required)
  -a|--app   application  Application name  (alphanumeric) (required)
  -d|--debug              Print Debug info
  -h|--help               Show Usage info

USAGE
exit 255
end

opts = GetoptLong.new(
    ["--debug", "-d", GetoptLong::NO_ARGUMENT],
    ["--help",  "-h", GetoptLong::NO_ARGUMENT],
    ["--user",  "-u", GetoptLong::REQUIRED_ARGUMENT],
    ["--app",   "-a", GetoptLong::REQUIRED_ARGUMENT]
)

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

if !opt["user"] || !opt["app"]
    p_usage
end

#
# Destroy remote application space
#

puts "Destroying remote application space: " + opt['app']

puts "Contacting server http://#{li_server}"
response = Net.HTTP.post_form(URI.parse("http://#{li_server}/destroy_http.php"),
                           {'username' => opt['user'],
                           'application' => opt['app']})

if response.code == '200'
    if debug: puts "HTTP response from server is #{response.body}"; end
    puts "Creation successful"
else
    puts "Problem with server. Response code was #{response.code}"
    if debug: puts "HTTP response from server is #{response.body}"; end
end

sleep_time = 2
attempt = 0

#
# Test several times, doubling sleep time between attempts.
#

puts "Confirming application #{opt['app']} is available"
while sleep_time < 65
    attempt+=1
    puts "  Attempt # #{attempt}"
    response = Net.HTTP.get_response(URI.parse("http://#{my_url}/health_check.php"))
    if response.code == "200" && response.body[0,1] == "1"
        puts "Server responded with #{response.code}"
        if debug: puts response.body; end
        puts
        puts "    sleeping #{sleep_time} seconds"
        sleep sleep_time
        sleep_time *= 2
    elsif response.code == "404"
        puts "Server responded with #{response.code}"
        if debug: puts response.body; end
        puts <<HC_NF
Connection success, health_check failed: Confirm removal at:

      http://#{my_url}

HC_NF
        exit 0
    else
        puts <<APPNOMO
Removal success: Confirm removal at:

      http://#{my_url}

APPNOMO
        exit 0
        
    end
end
puts "Unable to remove application space... problems"
exit 255
