#!/usr/bin/env ruby

require 'rubygems'
$:.unshift('/var/www/libra/lib')
require 'libra'

include Libra

#
# Update all app server identities to the current state
#
def update_all_app_server_identities
  start_time = Time.now.to_i
  servers = Server.find_all
  puts "Known servers:"
  servers.each do |server|
    puts '  ' + server.name
  end
  rhlogins = User.find_all_rhlogins
  user_count = rhlogins.length
  puts "RHLogins.length: #{user_count.to_s}"  
  rhlogins.each do |rhlogin|    
    user = User.find(rhlogin)
    if user
      puts "Updating apps for user: #{user.rhlogin}(#{user_count.to_s})"
      apps = user.apps
      apps.each_key do |app_sym|
        app_name = app_sym.to_s
        puts "Searching for app on known servers: #{app_name}"
        servers.each do |server|
          begin
            if server.has_app?(user, app_name)
              begin
                puts "Updating app: #{app_name} to server identity: #{server.name}"
                user.update_app_server_identity(app_name, server)
                break
              rescue Exception => e                
                puts "ERROR: Failed updating server identity for app: #{app_name} with server identity: #{server.name}"
                puts e.message
                puts e.backtrace
              end
            end
          rescue Exception => e
            puts "WARNING: Failed checking for app: #{app_name} on server: #{server.name}"
            puts e.message
            puts e.backtrace
          end
        end
      end
    else
      puts "WARNING:  Couldn't find user: #{rhlogin}"
    end
    user_count -= 1
  end
  end_time = Time.now.to_i
  total_time = end_time-start_time
  puts "Total execution time: #{total_time.to_s}s"
end

update_all_app_server_identities