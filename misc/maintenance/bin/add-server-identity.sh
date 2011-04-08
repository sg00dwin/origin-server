#!/usr/bin/env ruby
# Copyright © 2011 Red Hat, Inc. All rights reserved

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

require 'rubygems'
$:.unshift('/var/www/libra/lib')
require 'libra'

include Libra

#
# Update all app server identities to the current state
#
def update_all_app_server_identities
  servers = Server.find_all
  rhlogins = User.find_all_rhlogins
  rhlogins.each do |rhlogin|
    user = User.find(rhlogin)
    if user
      puts "Updating apps for user: #{user.rhlogin}" 
      apps = user.apps
      apps.each_key do |app_sym|
        app_name = app_sym.to_s
        puts "Searhing for app on known servers: #{app_name}"
        servers.each do |server|          
          if server.has_app?(user, app_name)
            puts "Updating app: #{app_name} to server identity: #{server.name}"
            User.update_app_server_identity(app_name, server)            
            break
          end
        end
      end
    end
  end
end

update_all_app_server_identities