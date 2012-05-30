# -*- coding: utf-8 -*-
#
# = libra.rb: Facter integration for li
#
# Author:: Mike McGrath
# 
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
#
# == Description
# 
# libra.rb for facter adds several additional li related facts which can then
# be queried by facter (and mcollective).  Examples include the number of git
# repositories on the host, customer information, etc.

require 'rubygems'
require 'parseconfig'

def get_node_config_value(key, default)
  config_file = ParseConfig.new('/etc/stickshift/stickshift-node.conf')
  val = config_file.get_value(key)
  return default if val.nil?
  val.gsub!(/\\:/,":") if not val.nil?
  val.gsub!(/[ \t]*#[^\n]*/,"") if not val.nil?
  val = val[1..-2] if not val.nil? and val.start_with? "\""
  val
end

#
# Count the number of git repos on this host
#
Facter.add(:git_repos) do
    git_repos_count = Dir.glob("/var/lib/stickshift/**/git/*.git").count
    setcode { git_repos_count }
end

#
# Setup the district
#
district_uuid = 'NONE'
district_active = false
if File.exists?('/etc/stickshift/district.conf')
  config_file = ParseConfig.new('/etc/stickshift/district.conf')
  district_uuid = config_file.get_value('uuid') ? config_file.get_value('uuid') : 'NONE'
  district_active = config_file.get_value('active') ? config_file.get_value('active') == "true" : false
end
Facter.add(:district_uuid) do
  setcode { district_uuid }
end
Facter.add(:district_active) do
  setcode { district_active }
end

#
# Pull public_ip and public_hostname out of the node_data config
#
public_ip = get_node_config_value("PUBLIC_IP", "UNKNOWN")
public_hostname = get_node_config_value("PUBLIC_HOSTNAME", "UNKNOWN")
Facter.add(:public_ip) do
  setcode { public_ip }
end
Facter.add(:public_hostname) do
  setcode { public_hostname }
end

#
# Find node_profile, max_apps, max_active_apps
#
node_profile = 'small'
max_apps = '0'
max_active_apps = '0'
if File.exists?('/etc/stickshift/resource_limits.conf')
  config_file = ParseConfig.new('/etc/stickshift/resource_limits.conf')
  node_profile = config_file.get_value('node_profile') ? config_file.get_value('node_profile') : 'small'
  max_apps = config_file.get_value('max_apps') ? config_file.get_value('max_apps') : '0'
  max_active_apps = config_file.get_value('max_active_apps') ? config_file.get_value('max_active_apps') : '0'
end
Facter.add(:node_profile) do
  setcode { node_profile }
end
Facter.add(:max_apps) do
  setcode { max_apps }
end
Facter.add(:max_active_apps) do
  setcode { max_active_apps }
end


#
# Find active capacity
#
Facter.add(:active_capacity) do
    git_repos =  Facter.value(:git_repos).to_f
    max_active_apps = Facter.value(:max_active_apps).to_f
    stopped_app_count = 0
    Dir.glob("/var/lib/stickshift/*").each { |app_dir|
        if File.directory?(app_dir) && !File.symlink?(app_dir)
            active = true
            Dir.glob(File.join(app_dir, '*', 'app-root', 'runtime', '.state')).each {|file|
                state = File.read(file).chomp
                if 'idle' == state || 'stopped' == state
                    active = false
                end
            }
            if not active
                stopped_app_count += 1
            end
        end
    }
    active_capacity = ( (git_repos - stopped_app_count) / max_active_apps ) * 100
    setcode { active_capacity.to_s }
end

#
# Find capacity
#
Facter.add(:capacity) do
    git_repos =  Facter.value(:git_repos).to_f
    max_apps = Facter.value(:max_apps).to_f
    capacity = ( git_repos / max_apps ) * 100
    setcode { capacity.to_s }
end


#
# Get sshfp record
#
Facter.add(:sshfp) do
    setcode { %x[/usr/bin/ssh-keygen -r $(hostname) -f /etc/ssh/ssh_host_rsa_key]}
end

=begin
#
# Lists customers on the host as well as what what git repos they currently own
#
if File.exists?("/var/lib/stickshift") && File.directory?("/var/lib/stickshift")
    # Determine customers on host and hosted info
    Dir.entries('/var/lib/stickshift/').each do |customer|
    
        if customer =~ /[A-Za-z0-9]/
            Facter.add("customer_#{customer}") do
                setcode do customer end
            end
        end
        # Repo counts for a customer
        if File.exists?("/var/lib/stickshift/#{customer}/git/")
            git_repos = Dir.glob("/var/lib/stickshift/#{customer}/git/*.git")
            Facter.add("git_cnt_#{customer}") do
                setcode do git_repos.size end
            end
        end
    end
end
=end

#
# List cartridges on the host
#   Convert from name-m.n.p to name-m.n
#   This is the *full* list.
#
Facter.add(:cart_list) do
    carts = []
    Dir.glob('/usr/libexec/stickshift/cartridges/*/').each do |cart|
        cart = File.basename(cart).sub(/^(.*)-(\d+)\.(\d+)\.?.*$/, '\1-\2.\3')
        carts << cart unless cart.nil? || cart == "embedded"
    end
    setcode { carts.join('|') }
end

#
# List embedded cartridges on the host
#   Convert from name-m.n.p to name-m.n
#   This is the *full* list.
#
Facter.add(:embed_cart_list) do
    carts = []
    Dir.glob('/usr/libexec/stickshift/cartridges/embedded/*/').each do |cart|
        cart = File.basename(cart).sub(/^(.*)-(\d+)\.(\d+)\.?.*$/, '\1-\2.\3')
        carts << cart unless cart.nil?
    end
    setcode { carts.join('|') }
end
