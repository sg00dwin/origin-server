#!/usr/bin/env ruby

require 'pp'

Dir.glob('*').each do |dir|
  if File.directory?(dir)
    puts "Syncing Jenkins job #{dir}..."
    `mkdir -p #{dir}`
    `scp root@jenkins:/var/lib/jenkins/jobs/#{dir}/config.xml #{dir}`
    `sed -i 's_<disabled>false</disabled>_<disabled>true</disabled>_' #{dir}/config.xml`
    puts "Done"
  end
end
