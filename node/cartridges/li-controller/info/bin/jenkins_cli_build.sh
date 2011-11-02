#!/usr/bin/env ruby

require 'rubygems'
require 'json'

STDOUT.sync = true
STDERR.sync = true

@username = ENV['JENKINS_USERNAME']
@password = ENV['JENKINS_PASSWORD']
@hostname = ENV['JENKINS_URL'].split("/")[-1]
@job_url = "/job/#{ARGV[0]}"


def get_jobs_info
  jobs = `curl -s http://#{@hostname}#{@job_url}/api/json`
  result = $?
  if result.exitstatus != 0
    puts "ERROR - Couldn't access jobs information"
    exit 290
  end
  JSON.parse(jobs.chomp)
end

def get_job_info(num)
  jobs = `curl -s http://#{@hostname}#{@job_url}/#{num}/api/json`
  result = $?
  if result.exitstatus != 0
    puts "ERROR - Couldn't access job information"
    exit 291
  end
  JSON.parse(jobs.chomp)
end

def get_build_num
  jobs_info = get_jobs_info
  jobs_info["lastBuild"] ? jobs_info["lastBuild"]["number"].to_i : 0
end

def schedule_build
  `curl -s -X POST --insecure https://#{@username}:#{@password}@#{@hostname}#{@job_url}/build`
  result = $?

  if result.exitstatus != 0
    puts "ERROR - Couldn't schedule job"
    exit 292
  end
end

# Source from - http://bit.ly/c1hcaB
def display_time(total_seconds)
  total_seconds = total_seconds.to_i
    
  days = total_seconds / 86400
  hours = (total_seconds / 3600) - (days * 24)
  minutes = (total_seconds / 60) - (hours * 60) - (days * 1440)
  seconds = total_seconds % 60
    
  display = ''
  display_concat = ''
  if days > 0
    display = display + display_concat + "#{days}d"
    display_concat = ' '
  end
  if hours > 0 || display.length > 0
    display = display + display_concat + "#{hours}h"
    display_concat = ' '
  end
  if minutes > 0 || display.length > 0
    display = display + display_concat + "#{minutes}m"
    display_concat = ' '
  end
  display = display + display_concat + "#{seconds}s"
  display
end

# Save the current build num
build_num = get_build_num

# Schedule a build
schedule_build

# See if there was a previous duration we can predict
last_duration = get_job_info(build_num)["duration"]
if last_duration
  display = display_time(last_duration / 1000)
  puts "Estimated build time: #{display}\n"
end

# Wait until a new build is kicked off
next_build_num = get_build_num
print "Waiting for build to schedule..."
until next_build_num == build_num + 1
  print "."
  sleep 1
  next_build_num = get_build_num
end
puts "Done"

# Block until a result shows up
print "Waiting for job to complete..."
json = get_job_info(next_build_num)
until json["result"]
  print "."
  sleep 1
  json = get_job_info(next_build_num)
end
puts "Done"

# Check the build result
if json["result"] == "SUCCESS"
  puts "Build Succeeded"
  exit 0
else
  puts "Build Failed"
  exit 1
end
