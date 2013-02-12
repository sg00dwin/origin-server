#!/usr/bin/env ruby
#
# PREREQS:
# 0) Put site into maintenance mode
# 1) Install newer version of redhat_sso
# 2) 'drush pm-disable redhat_sso'
# 3) 'drush pm-enable redhat_sso'
# 4) 'drush cc "module list" all'
# 5) restart httpd
# 6) update user settings (can't self create)
# 7) run migrate-names.rb
# 8) If there are zero duplicates, run
#    update users u left join new_users n on u.uid = n.uid set u.name = n.new_name;
#
# Revert features on server
# Create a new overview menu item that is disabled and points to
# "<front>"
# Update primary links menu to put community /community
# Check contexts
# Delete video, kb, and event breadcrumbs
#
require 'rubygems'
gem 'ruby-mysql'
require 'mysql'
require 'securerandom'

db = Mysql.real_connect('localhost', 'root', nil, 'libra', nil, '/var/lib/mysql/mysql.sock')

total_rows = db.prepare("select count(*) from users limit 10;").execute.first[0]
puts "Migrating #{total_rows} users"

db.query "drop table `new_users`;" rescue puts "Can't drop new_users, may not exist"
unless db.prepare("select * from users limit 1;").execute.fields.any?{ |f| f.name == 'old_name' }
  puts "Backing up old user names in old_name"
  if db.query "ALTER TABLE `users` ADD COLUMN old_name VARCHAR(60)"
    puts "FAILURE: Unable to back up user names: #{db.info}"
    exit
  end
  db.query "UPDATE users SET old_name = name"
  puts "Saved old names: #{db.info}"
end

raise "Can't create" if db.query <<-SQL
  CREATE TABLE `new_users` (
    `uid` int(10) unsigned not null,
    `name` VARCHAR(60) not null,
    `new_name` VARCHAR(60),
    PRIMARY KEY(`uid`),
    UNIQUE KEY `name` (`name`),
    UNIQUE KEY `new_name` (`new_name`)
  );
  SQL

PROTECTED = ['admin']

s_insert = db.prepare <<-SQL
  INSERT INTO new_users (uid, name, new_name) values(?, ?, ?)
  SQL

    #ON DUPLICATE KEY UPDATE new_name=NULL;
r = db.query "SELECT uid, name FROM users u order by access desc;"
r.each do |row|
  uid, name = row
  new_name = 
    if name.include?('@')
      sec = name.split('@')
      sec[-1] = sec.last.gsub(/(.*)\..*?$/, '\1')
      sec.join('')
    else
      name
    end.
      gsub(/(gmail|hotmail|microsoft|yahoo|redhat)$/i, '').
      gsub(/redhat|openshift/i, SecureRandom.base64(3)).
      gsub(/[^\w\-_]/, '')

  i, base_name = 0, new_name
  begin
    s_insert.execute(uid, name, new_name)
  rescue Mysql::ServerError::DupEntry
    puts "DUP: #{name} => #{new_name}"
    new_name = "#{base_name}_#{i += 1}"
    retry if i < 20
    $stderr.puts "FAILED: #{name} could not be made unique"
  end
end

s_missing = db.prepare("SELECT count(*) FROM new_users where new_name IS NULL;")
unmigrated_users = s_missing.execute.first[0]
if unmigrated_users > 0
  puts "Found #{unmigrated_users} users with nil new_names"
  r = db.query "SELECT name FROM new_users where new_name IS NULL limit 10;"
  puts r.map{ |row| row[0] }.join(' ')
  puts "MIGRATION FAILED\nYou will need to rerun after correcting the script."
else
  (stmt = db.prepare("update users u left join new_users n on u.uid = n.uid set u.name = n.new_name;")).execute
  puts "COMPLETE: Final update with: #{db.info}, check against count"
end

=begin
<<-SQL
  INSERT INTO new_users (uid, name, new_name)
    SELECT u.uid, u.name, u.name 
      FROM users u
    ON DUPLICATE KEY UPDATE new_name=NULL;
  SQL
r.each{ puts r.join(' ') }
=end
