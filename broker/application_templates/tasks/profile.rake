#!/usr/bin/env ruby

require 'myprofile'
require 'yaml'

namespace :profile do
  desc "Profile application template creation"
  task :templates do
    # Change the base for the hostname
    base = ENV['base'] || 'dev.rhcloud.com'

    # Default tests to run
    tests = [:deploy,:nslookup,:check_http,:delete]

    # Don't delete the apps if we specify keep
    tests.delete(:delete) if ENV['keep']

    # Get user credentials
    password = ask('Password: ',true)
    client = login(password)

    # Set default options for the test
    opts = {
      :domain => client.domains.first,
      :url_base => base,
      :tests => tests
    }

    # Select templates fo use
    templates = client.templates

    # Select specific types to test
    types = ['type','types'].map do |t|
      env = ENV[t]
      env.split(',').map{|x| x.to_sym} if env
    end.compact.flatten

    # Filter templates
    unless types.empty?
      templates.select!{|t| types.include?(template_type(t))}
    end

    # Run test for each template
    templates.each do |t|
      my_opts = opts.merge({
        :template => t,
        :type => template_type(t),
        :deploy_opts => {:template => t['uuid']},
      })
      Profile.new(my_opts).run
    end
  end
end

def template_type(t)
  YAML.load(t['descriptor_yaml'])['Name'].downcase.to_sym
end
