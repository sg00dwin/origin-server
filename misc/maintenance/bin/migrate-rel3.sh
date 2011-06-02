#!/usr/bin/env ruby

require 'rubygems'
require 'openshift'

include Libra

FRAMEWORKS = {'php-5.3.2' => 'php-5.3', 
              'rack-1.1.0' => 'rack-1.0', 
              'wsgi-3.2.1' => 'wsgi-3.2',
              'jbossas-7.0.0' => 'jbossas-7.0',
              'perl-5.10.1' => 'perl-5.10'}

#
# Migrate applications between release 2 and 3
# Remove framework patchlevel from s3 and apps
# Migration fix of UUID from user_info.json to application json
# Migration of remove top level app dir (TA460)
#
def migrate_rel3
  start_time = Time.now.to_i
  rhlogins = User.find_all_rhlogins
  user_count = rhlogins.length
  puts "RHLogins.length: #{user_count.to_s}"  
  rhlogins.each do |rhlogin|    
    user = User.find(rhlogin)
    if user
      puts "Updating apps for user: #{user.rhlogin}(#{user_count.to_s}) with uuid: #{user.uuid}"
      apps = user.apps
      apps.each do |app_name, app|
        from_type = app['framework']
        to_type = FRAMEWORKS[from_type]
        begin
          if to_type
            puts "Migrating app: #{app_name} to type: #{to_type}"
            app['framework'] = to_type
            user.update_app(app)
          else
            puts "ERROR: Failed migrating app: #{app_name} missing from_type: #{from_type}"
          end
        rescue Exception => e           
          puts "ERROR: Failed migrating app: #{app_name} to type: #{to_type}"
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

migrate_rel3