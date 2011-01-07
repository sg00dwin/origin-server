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
require 'resolv'

#
# Globals
#
ssh_config = "#{ENV['HOME']}/.ssh/config"
ssh_config_d = "#{ENV['HOME']}/.ssh/"
li_server = 'li.mmcgrath.libra.mmcgrath.net'
debug = false

def hostexist?(host)
    dns = Resolv::DNS.new
    resp = dns.getresources(host, Resolv::DNS::Resource::IN::A)
    return resp.any?
end

def p_usage
    puts <<USAGE

Usage: create_app
Create a new app libra project.

  -u|--user  username     Libra username    (alphanumeric) (required)
  -a|--app   application  Application name  (alphanumeric) (required)
  -r|--repo  path         Git Repo path (required)
  -t|--type  type         Type of app to create (php-5.3.2) (required)
  -b|--bypass             Bypass warnings
  -d|--debug              Print Debug info
  -h|--help               Show Usage info

USAGE
exit 255
end

opts = GetoptLong.new(
    ["--debug", "-d", GetoptLong::NO_ARGUMENT],
    ["--help",  "-h", GetoptLong::NO_ARGUMENT],
    ["--bypass","-b", GetoptLong::NO_ARGUMENT],
    ["--user",  "-u", GetoptLong::REQUIRED_ARGUMENT],
    ["--app",   "-a", GetoptLong::REQUIRED_ARGUMENT],
    ["--repo",  "-r", GetoptLong::REQUIRED_ARGUMENT],
    ["--type",  "-t", GetoptLong::REQUIRED_ARGUMENT]
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

if opt["type"]
    if !(opt["type"] =~ /^(php-5.3.2)$/)
        puts "type must be php-5.3.2"
        p_usage
    end
else
    puts "Type is required"
end

if !opt["repo"]
    puts "Git repo path is required"
end
if !opt["user"] || !opt["app"] || !opt["repo"] || !opt["type"]
    p_usage
end


#
# Send Warning
#

if !opt["yes"]
    puts <<WARNING
NOTICE: This is pre-alpha destructionware.  It is not tested, it
might break at any time.  While we'll generally leave it running, there is no
attempt at data protection or downtime minimization.  This is just a proof
of concept, do not store anything important here.

Thar be dragons this way.

Rules/Terms:
1) Don't put anything important here.
2) Know we won't be protecting data in any way and may arbitrarly destroy it
3) The service will go up and down as we are developing it, which may be a lot
4) We'll be altering your ~/.ssh/config file a bit, should be harmless.
5) Bugs should be sent to the libra team
6) This entire service may vanish as this is just a proof of concept.

WARNING

    print "Do you agree to the rules and terms? (y/n): "
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
# Create local git repo
#

puts "Creating local application space: " + opt['repo']
if File.directory?(opt['repo'])
    puts "We will not overwrite an existing git repo. Exiting"
    exit 255
end
Dir.mkdir(opt["repo"])

#
# head on over
#
old_dir = Dir.getwd
Dir.chdir(opt["repo"])
git = `git init`
if $?.exitstatus != 0
    puts "Error in calling git init"
    puts git
    exit 255
end

f = File.new(".git/config", "w")
f.puts <<GIT
[remote "libra"]
    url = ssh://#{opt['user']}@#{opt['app']}.#{opt['user']}.libra.mmcgrath.net/var/lib/libra/#{opt['user']}/git/#{opt['app']}.git/
GIT
f.close

#
# Add our skeleton files
#

f = File.new("index.php", "w")
f.puts <<HOMEPAGE
<html><title>#{opt['app']}</title>
<body>
<h1>Welcome to libra</h1>
<p>Place your application here</p>
<p>In order to commit to your new project, go to your projects git repo (created with the create_http command).  Make your changes, then run:</p>
<pre>git commit -a -m "Some commit message"
git push libra master</pre>
<p>Then reload this page</p>
</body>
</html>
HOMEPAGE
f.close

f = File.new("health_check.php", "w")
f.puts <<HEALTH
<?php
print 1;
?>
HEALTH
f.close

puts "add"

git = %x[git add *]

puts git
if $?.exitstatus != 0
    puts "Error in calling git add"
    puts git
    exit 255
end

puts "end"

git=%x[git commit -a -m "Initial libra app creation"]

puts git
if $?.exitstatus != 0
    puts "Error in calling git add"
    puts git
    exit 255
end


Dir.chdir(old_dir)

#
# Create remote application space
#

puts "Creating remote application space: " + opt['app']

puts "Contacting server http://#{li_server}"
response = Net::HTTP.post_form(URI.parse("http://#{li_server}/php/cartridge_do.php"),
                           {'cartridge' => opt['type'],
                            'action' => 'configure',
                            'args' => "#{opt['app']} #{opt['user']}"})

if response.code == '200'
    if debug
        puts "HTTP response from server is #{response.body}"
    end
    puts "Creation successful"
    if !(response.body =~ /exitcode=>0/)
        puts "An error has occured: #{response.body}"
        exit 253
    end
else
    puts "Problem with server. Response code was #{response.code}"
    puts "HTTP response from server is #{response.body}"
    exit 254
end

#
# Check / add new host to ~/.ssh/config
#

puts "Checking ~/.ssh/config"

my_url = "#{opt['app']}.#{opt['user']}.libra.mmcgrath.net"

found = false
File.open(ssh_config) do |sline|
    if sline =~ /my_url/
        found = true
        break
    end
end

if found
    puts "Found #{my_url} in ~/.ssh/config... No need to adjust"
else
    puts "    Adding #{my_url} to ~/.ssh/config"
    f = File.open(ssh_config, "a")
    f.puts <<SSH

# Added by libra app on #{`date`}
Host #{my_url}
    User #{opt['user']}
    IdentityFile ~/.ssh/libra_id_rsa

SSH
f.close
end

File.chmod(0600, ssh_config)
File.chmod(0700, ssh_config_d)

#
# Confirm that the host exists in DNS
#
puts "Confirming that host exists..."
loop = 0
while loop < 5 && !hostexist?(my_url)
    loop+=1
    puts "  retry # #{loop}"
    sleep 5
end

if loop == 5
    puts "Host could not be created and/or found..."
    exit 255
end

# 
# Push initial repo upstream (contains index and health_check)
#

Dir.chdir(opt["repo"])
puts "Doing initial test push."
puts 'system push'
system("git push -q libra master")
Dir.chdir(old_dir)

sleep_time = 2
attempt = 0

#
# Test several times, doubling sleep time between attempts.
#

puts "Confirming application #{opt['app']} is available"
while sleep_time < 65
    attempt+=1
    puts "  Attempt # #{attempt}"
    response = Net::HTTP.get_response(URI.parse("http://#{my_url}/health_check.php"))
    if response.code == "200" && response.body[0,1] == "1"
        puts <<LOOKSGOOD

Success!  Your application is now available at:

      http://#{my_url}/

To make changes to your application, commit to $new_repo_path/.
Then run 'git push libra master' to update your libra space

LOOKSGOOD
        exit 0
    end
    puts "Server responded with #{response.code}"
    puts response.body
    puts
    puts "    sleeping #{sleep_time} seconds"
    sleep sleep_time
    sleep_time *= 2
end
puts "Unable to find or access the site... problems"
exit 255
