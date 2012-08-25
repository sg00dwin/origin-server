#!/usr/bin/env ruby

require 'myprofile'
require 'yaml'

namespace :profile do
  task :setup do
    unless @opts
      @opts = {}

      # Get user credentials
      password = ask('Password: ',true)
      @opts[:client] = login(password)

      # Change the base for the hostname
      @opts[:base] = ENV['base'] || 'dev.rhcloud.com'

      # Get specific types to test
      @opts[:types] = ['type','types'].map do |t|
        env = ENV[t]
        env.split(',').map{|x| x.to_sym} if env
      end.compact.flatten

      # Specify whether we should keep apps
      @opts[:keep] = ENV['keep']
    end
  end

  desc "Profile application template creation"
  task :templates => :setup do
    # Default tests to run
    tests = [:deploy,:nslookup,:check_http,:delete]

    # Don't delete the apps if we specify keep
    tests.delete(:delete) if @opts[:keep]

    # Set default options for the test
    opts = default_opts({
      :tests => tests
    })

    # Run test for each template
    get_templates.each do |t|
      my_opts = opts.merge({
        :template => t,
        :type => template_type(t),
        :opts =>{
          :deploy => {:template => t['uuid']},
        }
      })
      Profile.new(my_opts).run
    end
  end

  desc "Profile application creation from git"
  task :git => :setup do
    # Default tests to run
    tests = [:deploy,:embed,:nslookup,:git,:check_http,:delete]

    # Don't delete the apps if we specify keep
    tests.delete(:delete) if @opts[:keep]

    # Set default options for the test
    opts = default_opts({
      :tests => tests
    })

    # Run test for each template
    get_applications.each do |t|
      target = YAML.load_file(t.target)
      my_opts = opts.merge({
        :type => t.name,
        :opts => {
          :deploy => {:cartridge => target[:cartridge]},
          :embed  => target[:embed],
          :git    => target[:metadata][:git_url]
        }
      })
      Profile.new(my_opts).run
    end
  end
end

def get_applications
  application_templates.filter(@opts[:types]) do |t|
    t.name.downcase.to_sym
  end
end

def get_templates
  @client.templates.filter(@opts[:types]) do |t|
    template_type(t)
  end
end

def template_type(t)
  YAML.load(t['descriptor_yaml'])['Name'].downcase.to_sym
end

def default_opts(opts = {})
  {
    :domain => @opts[:client].domains.first,
    :url_base => @opts[:base],
  }.merge(opts)
end
