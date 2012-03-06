#!/usr/bin/ruby

require 'rubygems'
require 'rhc-common'
require 'pp'
require 'rest-client'

#$create_url='curl -k -X POST -H "Accept: application/xml" --user "%s:%s" https://%s/broker/rest/domains/%s/applications'
#$scale_url="#{$create_url}/%s/events"

$base_url='https://%s/broker/rest'
$create_url='/domains/%s/applications'
$scale_url='/domains/%s/applications/%s/events'
$cartridges_url='/cartridges'
$domain_url='/domains'

class Gear_scale_ctl
  def initialize(action, opts)
    if action ==  'gear-scale-ctl.rb'
      $stderr.puts 'Call gear-scale-ctl via an alias: add-gear, remove-gear, create-app'
      exit 2
    end

    if not ['add-gear', 'remove-gear', 'create-app'].include? action
      usage opts
    end

    @action = action
    @opts = opts

    base_url = $base_url % opts["server"]
    user, password, url, payload = case action
      when 'add-gear'
        [
#          File.read("/var/lib/libra/#{opts['app']}-#{opts['namespace']}/.auth/iv").chomp,
#          File.read("/var/lib/libra/#{opts['app']}-#{opts['namespace']}/.auth/token").chomp,
          opts['rhlogin'], opts['password'],
          "#{base_url}#{$scale_url % [opts['namespace'], opts['app']]}",
          {'event' => 'scale-up'}
        ]
      when 'remove-gear'
        [
#          URI.escape(File.read("/var/lib/libra/#{opt['app']}-#{opt['namespace']}/.auth/token")),
#          URI.escape(File.read("/var/lib/libra/#{opt['app']}-#{opt['namespace']}/.auth/iv")),
          opts['rhlogin'], opts['password'],
          "#{base_url}#{$scale_url % [opts['namespace'], opts['app']]}",
          {'event' => 'scale-down'}
        ]
      when 'create-gear'
        [
          opts['rhlogin'], opts['password'],
          "#{base_url}#{$create_url % opts['namespace']}",
          {'name' => opts["app"], 'cartridge' => opts["type"], 'scale' => 'true'}
        ]
    end

    request = RestClient::Request.new(:method => :post, :url => url,
        :user => user, :password => password,
        :headers => {:accept => 'application/json'},
        :payload => payload
        )

    response = request.execute()
    unless 200 == response.code
      raise response
    end
  end

  def self.cartridges(opts) 
    base_url = $base_url % opts['server']
    request = RestClient::Request.new(:method => :get, :url => "#{base_url}#{$cartridges_url}", 
        :user => opts['rhlogin'], :password => opts["password"],
        :headers => {:accept => 'application/json'})
    response = request.execute()
    if 200 == response.code
      payload = JSON.parse(response.body)
      rows = payload['data'].select {|c| c['type'] == 'standalone'}
      rows.map {|c| c['name']}
    else
      []
    end
  end

  def self.domain(opts)
    base_url = $base_url % opts['server']
    request = RestClient::Request.new(:method => :get, :url => "#{base_url}#{$domain_url}", 
        :user => opts['rhlogin'], :password => opts["password"],
        :headers => {:accept => 'application/json'})
    response = request.execute()
    if 200 == response.code
      JSON.parse(response.body)
    else
      raise "code: #{response.code} : #{response.body}"
    end
  end
end

def usage(opts)
  types = Gear_scale_ctl.cartridges(opts)
  rhlogin = get_var('default_rhlogin') ? "Default: #{get_var('default_rhlogin')}" : "required"

  $stderr.puts <<USAGE

Usage: #{$0}

Add gear to application:
  Usage: add-gear -a|--app <application name> -l|--rhlogin <user> -p|--password <password> -n|--namespace <namespace uuid> [-h|--host <hostname>]

Remove gear from application:
  Usage: remove-gear -a|--app <application name> -l|--rhlogin <user> -p|--password <password> -n|--namespace <namespace uuid> [-h|--host <hostname>]

Create scalable application (used for testing...):
  Usage: create-app -a|--app <application name> -l|--rhlogin <user> -p|--password <password> -n|--namespace <namespace uuid> -t|--type <cartridge type> [-h|--host <hostname>]


  -a|--app         application  Name for your application (alphanumeric - max <rest call?> chars) (required)
  -n|--namespace   namespace    Namespace for your application(s) (alphanumeric - max <rest call?> chars) (required)
  -l|--rhlogin     rhlogin      Red Hat login (RHN or OpenShift login with OpenShift Express access) (#{rhlogin})
  -p|--password    password     RHLogin password (optional, will prompt)
  -h|--host        libra server host running broker
  -t|--type        cartridges   list of available cartridge types (#{types.join(', ')}
  -d|--debug                    Print Debug info
  -h|--help                     Show Usage info

USAGE
#  --config  path               Path of alternate config file
#  --timeout #                  Timeout, in seconds, for connection
  exit 255
end

opts = {
  "server" => get_var('libra_server'),
  "rhlogin" => get_var('default_rhlogin')
}

begin
  args = GetoptLong.new(
    ["--debug",     "-d", GetoptLong::NO_ARGUMENT],
    ["--help",      "-h", GetoptLong::NO_ARGUMENT],
    ["--app",       "-a", GetoptLong::REQUIRED_ARGUMENT],
    ["--password",  "-p", GetoptLong::OPTIONAL_ARGUMENT],
    ["--namespace", "-n", GetoptLong::REQUIRED_ARGUMENT],
    ["--type",      "-t", GetoptLong::OPTIONAL_ARGUMENT],
    ["--server",    "-s", GetoptLong::OPTIONAL_ARGUMENT],
    ["--rhlogin",   "-l", GetoptLong::OPTIONAL_ARGUMENT]
  )

  args.each {|opt, arg| opts[opt[2..-1]] = arg.to_s }

  if opts["rhlogin"].nil? || opts["rhlogin"].empty? \
        || opts["server"].nil? || opts["server"].empty? \
        || opts["app"].nil? || opts["app"].empty? \
        || opts['password'].nil? || opts['password'].empty?
    usage opts
  end

rescue Exception => e
  usage opts
end

domain = Gear_scale_ctl.domain(opts)
opts['namespace'] = domain['data'][0]['namespace']

o = Gear_scale_ctl.new(File.basename($0), opts)

exit 0
