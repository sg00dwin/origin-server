#!/usr/bin/env ruby

require 'rubygems'
require 'openshift'

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
      puts "Updating apps for user: #{user.rhlogin}(#{user_count.to_s}) with uuid: #{user.uuid}"
      apps = user.apps
      apps.each do |app_name, app|
        puts "Searching for app on known servers: #{app_name}"
        found = false        
        servers.each do |server|
          begin            
            if server.has_app?(app, app_name)
              begin
                puts "Updating app: #{app_name} to server identity: #{server.name}"
                app['server_identity'] = server.name
                user.update_app(app, app_name)
                found = true
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
        if !found
          puts "WARNING: Failed to find app on known servers: #{app_name}"
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