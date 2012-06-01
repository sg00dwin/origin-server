#!/usr/bin/env ruby

require 'myprofile'
require 'yaml'

namespace :profile do
  desc "Profile application template creation"
  task :templates do
    base = ENV['base'] || 'dev.rhcloud.com'

    password = ask('Password: ',true)
    client = login(password)

    opts = {
      :domain => client.domains.first,
      :url_base => base,
      :tests => [:deploy,:nslookup,:check_http,:delete],
    }

    templates = client.templates

    templates.each do |t|
      type = YAML.load(t['descriptor_yaml'])['Name'].downcase.to_sym
      name = (0...4).map{65.+(rand(25)).chr}.join

      my_opts = opts.merge({
        :template => t,
        :name => name,
        :type => type,
        :deploy_opts => {:template => t['uuid']},
      })
      Profile.new(my_opts).run
    end
  end
end
