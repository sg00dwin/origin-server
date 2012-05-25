#!/usr/bin/env ruby

namespace :templates do
  desc "Create templates based on information in templates directory"
  task :create do
    YAML.load_file('templates.yml').each do |name|
      template = ApplicationTemplate.new(name)
      puts "Creating #{template.name}"
      cmd = template.template_function
      puts `#{cmd}`
    end
  end
end
