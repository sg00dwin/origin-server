#!/usr/bin/env ruby
# Usage: ./migrate-2.1.3.sh > out.txt
require 'rubygems'
require 'openshift'

include Libra

RHLOGINS=nil #['username']

#
#  Migrate the specified app on the node
#
def migrate_app_on_node(user, app, app_name)
  Helper.rpc_exec('libra', app['server_identity']) do |client|
    client.migrate(:uuid => app['uuid'],
                   :application => app_name,
                   :app_type => app['framework'],
                   :namespace => user.namespace,
                   :version => '2.1.3') do |response|
      exit_code = response[:body][:data][:exitcode]
      output = response[:body][:data][:output]
      if (output.length > 0)
        puts "Migrate on node output: #{output}"
      end
      if exit_code != 0
        puts "Migrate on node exit code: #{exit_code}"
        raise "Failed migrating app '#{app_name}' with uuid '#{app['uuid']}' on node '#{app['server_identity']}'"
      end
    end
  end
end

#
# Migrate applications between 2.1.2 and 2.1.3
# Add env variables
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
          migrate_app_on_node(user, app, app_name)
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