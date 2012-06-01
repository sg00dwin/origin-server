#!/usr/bin/env ruby

require 'template_profile'

$logger = Logger.new(logfile('debug'))

desc "Profile application template creation"
task :profile do
  password = ask('Password: ',true)
  client = login(password)

  opts = {
    :domain => client.domains.first,
    :server => 'int.rhcloud.com'
  }

  $logger.debug "Getting templates"
  templates = client.templates

  $logger.debug "Starting loop"
  templates.each do |t|
    host = YAML.load(t['descriptor_yaml'])['Name']
    profile(opts.merge({
      :template => t ,
      :name => host,
      :deploy_opts => {:template => t['uuid']},
      :host => "%s-%s.%s" % [host,opts[:domain].id,opts[:server]]
    }))
  end
end
