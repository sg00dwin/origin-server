#!/usr/bin/ruby

require 'rubygems'
require 'openshift'
include Libra

puts "Testing broadcast call"
server = Server.find_available
raise "Broadcast call failed" unless server

puts "Testing direct call"
fact = server.get_fact_direct("operatingsystem")
raise "Direct failed" unless fact
