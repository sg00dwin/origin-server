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

# Save the current build num
build_num = get_build_num

# Schedule a build
schedule_build

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
  puts "SUCCESS"
  exit 0
else
  puts "FAILED"
  exit 1
end
