#!/usr/bin/env ruby

namespace :descriptors do
  desc "Deploy an application based on template"
  task :deploy do
    client = login
    templates = client.templates
    puts "Which template would you like to deploy?"
    templates.each_index do |index|
      template = templates[index]
      puts "%2d: %s" % [index, template["display_name"]]
    end
    index = ask("Selection: ", Integer)
    name = ask("Name for application: ", String)

    target = templates[index]
    puts "Deploying %s (%s)" % [target['display_name'], target['uuid']]

    domain = client.domains.first
    domain.add_application(name,{:template => target['uuid']})
  end
end
