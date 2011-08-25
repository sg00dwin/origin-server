#!/usr/bin/env ruby
# Usage: ./migrate-cname.sh > out.txt
require 'rubygems'
require 'openshift'

include Libra

RHLOGINS=nil #['username']

#
# Migrate dns from ARecords to CNAME
#
def migrate
  start_time = Time.now.to_i
  puts "Getting all RHLogins..." 
  rhlogins = RHLOGINS || User.find_all_rhlogins
  user_count = rhlogins.length
  puts "RHLogins.length: #{user_count.to_s}"
  rhlogins.each do |rhlogin|
    user = User.find(rhlogin)
    if user
      puts ""
      puts "######################################################"
      puts "Updating apps for user: #{user.rhlogin}(#{user_count.to_s}) with uuid: #{user.uuid}"
      apps = user.apps
      apps.each do |app_name, app|
        begin
          puts "Migrating app '#{app_name}' with uuid '#{app['uuid']}' on node '#{app['server_identity']}' for user: #{rhlogin}"
          server = Server.new(app['server_identity'])
          dyn_retries = 2
          auth_token = Server.dyn_login(dyn_retries)
          server.dyn_delete_sshfp_record(app_name,  user.namespace, auth_token, dyn_retries)
          server.dyn_delete_a_record(app_name,  user.namespace, auth_token, dyn_retries)
          server.dyn_create_cname_record(app_name,  user.namespace, auth_token, dyn_retries)
          Server.dyn_publish(auth_token, dyn_retries)
          Server.dyn_logout(auth_token, dyn_retries)
        rescue Exception => e
          puts "ERROR: Failed migrating app: #{app_name} with uuid: #{app['uuid']} for user: #{rhlogin}"
          puts e.message
          puts e.backtrace
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

migrate