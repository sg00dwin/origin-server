#!/usr/bin/env ruby

namespace :templates do
  desc "List available templates"
  task :list do
    client = login
    templates = client.templates
    if templates.empty?
      puts "No templates currently available"
    else
      templates.each do |t|
        puts "%s (%s)" % [t['display_name'],t['uuid']]
      end
    end
  end
end
