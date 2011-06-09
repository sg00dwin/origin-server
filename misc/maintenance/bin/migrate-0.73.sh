#!/usr/bin/env ruby
# Usage: ./migrate-rel3.sh > out.txt
require 'rubygems'
require 'openshift'

include Libra

RHLOGINS=nil #['appname']

FRAMEWORKS = {'php-5.3.2' => 'php-5.3', 
              'rack-1.1.0' => 'rack-1.1', 
              'wsgi-3.2.1' => 'wsgi-3.2',
              'jbossas-7.0.0' => 'jbossas-7.0',
              'perl-5.10.1' => 'perl-5.10'}
              
#
#  Migrate the specified app on the node
#
def migrate_app_on_node(user, app, app_name, old_app_type, new_app_type)
  Helper.rpc_exec('libra', app['server_identity']) do |client|
    client.migrate(:uuid => app['uuid'],
                   :application => app_name,
                   :app_type => old_app_type,
                   :namespace => user.namespace,
                   :version => '0.73') do |response|
      exit_code = response[:body][:data][:exitcode]
      output = response[:body][:data][:output]
      if (output.length > 0)
        puts "Migrate on node output: #{output}"
      end
      if exit_code != 0
        puts "Migrate on node exit code: #{exit_code}"
        raise "Failed migrating app '#{app_name}' with uuid '#{app['uuid']}' on node '#{app['server_identity']}'"
      else
        puts "Restarting app '#{app_name}' on node '#{app['server_identity']}'"
        server = Server.new(app['server_identity'])
        result = nil
        (1..2).each do
          result = server.execute_direct(new_app_type, 'restart', "#{app_name} #{user.namespace} #{app['uuid']}")[0]
        end
        if (result && defined? result.results)
          output = result.results[:data][:output]
          exit_code = result.results[:data][:exitcode]
          if (output.length > 0)
            puts "Restart on node output: #{output}"
          end
          if exit_code != 0
            puts "Restart on node exit code: #{exit_code}"
            raise "Failed restarting app '#{app_name}' with uuid '#{app['uuid']}' on node '#{app['server_identity']}'"
          end
        end
      end
    end
  end
end

#
# Migrate applications between release launch and 0.73
# Remove framework patchlevel from s3 and apps
# Migration fix of UUID from user_info.json to application json
# Migration of remove top level app dir (TA460)
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
            to_type = from_type
            puts "WARNING: From type '#{from_type}' not found migrating app: #{app_name}"
          end
          if !app['uuid']
            puts "Adding uuid to app: #{app_name} to type: #{user.uuid}"
            app['uuid'] = user.uuid
          else
            puts "WARNING: Application '#{app_name}' already has uuid: #{app['uuid']}"
          end
          puts "Migrating app in s3 '#{app_name}' with uuid '#{app['uuid']}' for user: #{rhlogin}"            
          user.update_app(app, app_name)
          if app['server_identity']
            puts "Migrating app '#{app_name}' with uuid '#{app['uuid']}' on node '#{app['server_identity']}' for user: #{rhlogin}"
            migrate_app_on_node(user, app, app_name, from_type, to_type)
          else        
            puts "Missing server identity for app '#{app_name}' with uuid '#{app['uuid']}' for user: #{rhlogin}"            
          end
        rescue Exception => e
          puts "ERROR: Failed migrating app: #{app_name} to type: #{to_type} and uuid: #{user.uuid} for user: #{rhlogin}"
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

migrate