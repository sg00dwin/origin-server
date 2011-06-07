#!/usr/bin/env ruby
# Usage: ./migrate-rel3.sh > out.txt
require 'rubygems'
require 'openshift'

include Libra

FRAMEWORKS = {'php-5.3.2' => 'php-5.3', 
              'rack-1.1.0' => 'rack-1.0', 
              'wsgi-3.2.1' => 'wsgi-3.2',
              'jbossas-7.0.0' => 'jbossas-7.0',
              'perl-5.10.1' => 'perl-5.10'}
              
#
#  Migrate the specified app on the node
#
def migrate_app_on_node(user, server_name, app, app_name, app_type)
  Helper.rpc_exec('libra', server_name) do |client|
    client.migrate(:uuid => app['uuid'],
                   :application => app_name,
                   :app_type => app_type,
                   :version => '3') do |response|
      exit_code = response[:body][:data][:exitcode]  
      puts "Exit code: #{exit_code}"      
      output = response[:body][:data][:output]
      if exit_code != 0
        raise "Failed migrating app '#{app_name}' with uuid '#{app['uuid']}' on node '#{server_name}'"
      end
    end
  end
end

#
# Migrate applications between release 2 and 3
# Remove framework patchlevel from s3 and apps
# Migration fix of UUID from user_info.json to application json
# Migration of remove top level app dir (TA460)
#
def migrate_rel3
  start_time = Time.now.to_i
  puts "Getting all RHLogins..." 
  rhlogins = User.find_all_rhlogins
  user_count = rhlogins.length
  puts "RHLogins.length: #{user_count.to_s}"  
  rhlogins.each do |rhlogin|
    user = User.find(rhlogin)
    if user
      puts "Updating apps for user: #{user.rhlogin}(#{user_count.to_s}) with uuid: #{user.uuid}"
      apps = user.apps
      if apps.length > 1
        puts "WARNING: Application length > 1 #{apps.pretty_inspect} for user: #{rhlogin}"
        puts "WARNING: Will only migrate the first application"
      end
      apps.each do |app_name, app|
        from_type = app['framework']
        to_type = FRAMEWORKS[from_type]
        begin
          if to_type
            puts "Migrating app: #{app_name} to type: #{to_type}"
            app['framework'] = to_type
          else
            puts "WARNING: From type '#{from_type}' not found migrating app: #{app_name}"
          end
          if !app['uuid']
            puts "Adding uuid to app: #{app_name} to type: #{user.uuid}"
            app['uuid'] = user.uuid
          else
            puts "WARNING: Application '#{app_name}' already has uuid: #{app['uuid']}"
          end
          puts "Migrating app in s3 '#{app_name}' with uuid '#{app['uuid']}' for user: #{rhlogin}"            
          #user.update_app(app)
          if app['server_identity']
            puts "Migrating app '#{app_name}' with uuid '#{app['uuid']}' on node '#{app['server_identity']}' for user: #{rhlogin}"
            migrate_app_on_node(user, app['server_identity'], app, app_name, app['framework'])
          else            
            puts "Missing server identity for app '#{app_name}' with uuid '#{app['uuid']}' for user: #{rhlogin}"            
          end
        rescue Exception => e
          puts "ERROR: Failed migrating app: #{app_name} to type: #{to_type} for user: #{rhlogin}"
          puts e.message
          puts e.backtrace
        end
        break # Only handle the first app
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

migrate_rel3