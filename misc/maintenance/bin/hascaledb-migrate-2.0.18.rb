#!/usr/bin/env ruby
require '/var/www/stickshift/broker/config/environment'

CloudUser.find_all(nil).each { |u|
  u.applications.each { |a|
    if a.scalable and not (a.embedded.keys & ["mysql-5.1","postresql-8.4", "mongodb-2.2"]).empty?
       puts a.name
       a.elaborate_descriptor
       a.execute_connections
    end
  }
}
