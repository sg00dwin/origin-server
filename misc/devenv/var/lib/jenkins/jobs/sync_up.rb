#!/usr/bin/env ruby

require 'pp'

Dir.glob('*').each do |dir|
  if File.directory?(dir)
    puts "Syncing Jenkins job #{dir}..."
    `scp #{dir}/config.xml root@jenkins:/var/lib/jenkins/jobs/#{dir}/`
    puts "Done"
  end
end
