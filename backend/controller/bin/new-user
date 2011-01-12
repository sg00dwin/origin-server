#!/usr/bin/ruby

require 'rubygems'
require 'right_aws'
require 'getoptlong'
require 'json'
require 'parseconfig'

def p_usage
    puts <<USAGE

Usage: new_user
Creates a new user by storing their info in S3

    -u|--user   username    Libra username (alphanumeric) (required)
    -e|--email  email       Email address (required)
    -s|--ssh    SSH key     Sublic SSH key to use
    -a|--alter  alter       Alter / Update user info
    -h|--help   help        Show usage info
USAGE
    exit 255
end

opts = GetoptLong.new(
    ['--user', '-u', GetoptLong::REQUIRED_ARGUMENT],
    ['--email', '-e', GetoptLong::REQUIRED_ARGUMENT],
    ['--ssh', '-s', GetoptLong::REQUIRED_ARGUMENT],
    ['--alter', '-a', GetoptLong::NO_ARGUMENT]
)

opt = {}
opts.each do |o, a|
    opt[o[2..-1]] = a.to_s
end

if opt['help']
    p_usage
end

p_usage unless opt['user'] =~ /^[a-zA-Z0-9]+$/
p_usage unless opt['email'] =~ /^[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/
p_usage unless defined? opt['ssh'] || (opt['ssh'] == Base64.encode64(Base64.decode64(opt['ssh'])).gsub(/\n/, '')) and opt['ssh'] =~ /^AAAAB3NzaC1yc2EA/

config_path = File.exists?('libra_s3.conf') ? 'libra_s3.conf' : '/etc/libra/libra_s3.conf'

begin
    config = ParseConfig.new(config_path)
rescue Errno::EACCES => e
    puts "Could not open config file: #{e.message}"
    exit 253
end

aws_access_key_id = config.get_value('aws_access_key_id')
aws_secret_access_key = config.get_value('aws_secret_access_key')

s3 = RightAws::S3Interface.new(aws_access_key_id, aws_secret_access_key, params = {:logger => Logger.new('/dev/null')})

# Check if user already exists:
begin
    json_data = s3.get('libra', "user_info/#{opt['user']}.json")
    unless opt['alter']
        puts "User already exists!  To overwrite or change, use --alter"
        exit 254
    end
rescue RightAws::AwsError => e
end

json_data = JSON.generate(
            {:username => opt['user'],
            :email => opt['email'],
            :ssh => opt['ssh']})

s3.put('libra', "user_info/#{opt['user']}.json", json_data)
