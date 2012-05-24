#!/usr/bin/env ruby

namespace :descriptors do
  desc "Create scripts for destroying current templates"
  task :destroy do
    client = login
    templates = client.templates
    dir = templates_dir

    script = File.join(dir,"destroy_templates.sh")
    my_log("Creating script to destroy templates...") do
      File.open(script,'w',0775) do |f|
        templates.each do |t|
          f.puts "%s #%s"% [template_command({:command => 'remove', :uuid => t['uuid']}), t['display_name']]
        end
      end
    end
  end
end
