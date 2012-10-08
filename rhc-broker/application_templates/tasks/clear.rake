#!/usr/bin/env ruby

namespace :descriptors do
  desc "Clears all metadata and descriptors (leaves targets)"
  task :clear do
    application_templates.each do |template|
      [:metadata, :descriptor, :script].each do |type|
        file = template.file_for(type)
        File.delete(file) if File.exists?(file)
      end
    end
  end
end
