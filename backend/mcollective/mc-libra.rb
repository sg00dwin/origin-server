#!/usr/bin/env ruby

require 'rubygems'
require 'mcollective'
require 'parseconfig'
require 'json'
require 'right_aws'

include MCollective::RPC

#
# S3 connection info
#
config_path = File.exists?('libra_s3.conf') ? 'libra_s3.conf' : '/etc/libra/libra_s3.conf'
begin
    config = ParseConfig.new(config_path)
rescue Errno::EACCES => e
    puts "Could not open config file: #{e.message}"
    exit 253
end

aws_access_key_id = config.get_value('aws_access_key_id')
aws_secret_access_key = config.get_value('aws_secret_access_key')

#
# Parse options
#
options = rpcoptions do |parser, options|
    parser.define_head "Control libra agent"
    parser.banner = "Usage: mc-libra [options]"
    parser.on('--cartridge CARTRIDGE', 'Cartridge type to call (php-5.3.2)') {|v| options[:cartridge] = v}
    parser.on('-a', '--action ACTION', 'Action to call') {|v| options[:action] = v}
    parser.on('-n', '--name NAME', 'Name of application') {|v| options[:name] = v}
    #parser.on('-r', '--args ARGS', 'Args to pass') {|v| options[:args] = v}
    parser.on('-u', '--user USER', 'User to act on') {|v| options[:user] = v}
end

verbose = options[:verbose]

unless options.include?(:cartridge) or options[:cartridge] =~ /^(php-5.3.2)$/
    puts "You need to specify a proper cartridge"
    exit 254
end

unless options.include?(:action) or options[:action] =~ /^(configure|deconfigure|info|post-install|post_remove|pre-install|reload|restart|start|status|stop)$/
    puts "Specify supported action:"
    puts "configure,deconfigure,info,post-install,post_remove,pre-install,reload,restart,start,status,stop"
    exit 253
end

unless options.include?(:name) or options[:name] =~ /^.+$/
    puts "Specify app name"
    exit 252
end

unless options.include?(:user) or options[:user] =~ /^[a-zA-Z0-9]+$/
    puts "Specify user"
    exit 252
end

#
# First calls, quickly find a reasonably available host
#
rpc_facts = rpcclient('rpcutil', :options => options)
rpc_facts.progress = false
rpc_facts.timeout = 1

git_repos = {:repo_count => 100000} # Arbitrarly large value

rpc_facts.get_fact(:fact => 'git_repos') do |resp|
    next unless Integer(resp[:body][:statuscode]) == 0
    repo_count = Integer(resp[:body][:data][:value])
    puts "#{resp[:senderid]}: #{resp[:body][:data][:value]}" if verbose
    if repo_count < git_repos[:repo_count]
        git_repos[:repo_count] = repo_count
        git_repos[:target] = resp[:senderid]
    end
end
puts "Using node #{git_repos[:target]}" if verbose
options[:filter]["identity"] = git_repos[:target]
options[:mcollective_limit_targets] = "1"

#
# Check if customer already exists on host, create if not
#
create_user=nil
rpc_facts.get_fact(:fact => "customer_#{options[:user]}") do |resp|
    create_user=true unless resp[:body][:data][:value] == options[:user]
end

if create_user
    s3 = RightAws::S3Interface.new(aws_access_key_id, aws_secret_access_key, params = {:logger => Logger.new('/dev/null')})
    begin
        json_data = s3.get('libra', "user_info/#{options[:user]}.json")
    rescue RightAws::AwsError => e
        if e.message =~ /^NoSuchKey/
            puts "Error: Trying to create an application for a user that does not exist"
            puts "Please create user, then try again"
            puts e.message if verbose
        end
        exit 222
    end
    user_info = JSON.parse(json_data[:object])
    rpc_user = rpcclient('libra', :options => options)
    rpc_user.progress = false
    user_resp = rpc_user.cartridge_do(:cartridge => 'li-controller-0.1',
                            :action => 'configure',
                            :args => "-c #{user_info["username"]} -e #{user_info["email"]} -s #{user_info["ssh"]}")
    unless user_resp[0][:data][:exitcode] == 0
        p user_resp if verbose
        puts "remote user creation failed: #{user_resp[0][:data][:output]}"
        exit 233
    end
    rpc_user.disconnect
end

rpc_facts.disconnect

# 
# Create application on new host
# 
mc = rpcclient('libra', :options => options)
mc.progress = false

# The below option may be needed for performance
#mc.limit_targets = "10%"
#
resp = mc.cartridge_do(:cartridge => options[:cartridge],
                        :action => options[:action],
                        :args => "#{options[:name]} #{options[:user]}")

mc.disconnect

puts "Exit code: #{resp[0][:data][:exitcode]}" if verbose
if resp[0][:data][:exitcode] == 0
    puts "Success!"
else
    puts "Failed to create remote application: #{resp[0][:data][:output]}"
    exit 203
end
#resp = mc.echo(:msg => "woo hoo")

# vi:tabstop=4:expandtab:ai
