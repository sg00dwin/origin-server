#!/usr/bin/env ruby

namespace :descriptors do
  desc "Create applications and retrieve their descriptors"
  task :generate do
    puts "Creating application descriptors"
    client = login
    domain = client.domains.first

    # Applications comes from lib/descriptors.rb
    applications.each do |name|
      puts "Checking template for #{name}"
      target = target_for(name)
      unless File.exists?(target)
        puts "no target specified, skipping"
        next
      end
      # load options from target
      opts = YAML.load_file(target)
      # Check to see if descriptor already exists exists
      if descriptor_exists?(name)
        puts "Descriptor already exists for #{name}...reusing"
      else
        puts "Creating application #{name}"

        # Destroy application if it already exists
        if(app = client.find_application("#{name}").first)
          destroy_app(app)
        end

        # Create new application
        app = my_log("Creating application #{name}..."){
          domain.add_application(name, {:cartridge => opts[:cartridge]})
        }

        # Embed any carts we need
        opts[:embed].each do |cart|
          my_log("Embedding cartridge: #{cart}..."){
            app.add_cartridge(cart)
          }
        end if opts[:embed]

        # Write the desciptor file
        File.open(descriptor_for(name),'w') do |f|
          f.write app.descriptor
        end

        # Destroy app
        destroy_app(app)
      end

      # Dump the metadata JSON
      File.open(metadata_for(name),'w') do |f|
        f.write JSON.pretty_generate(opts[:metadata])
      end

      # Create deploy script
      File.open(deploy_script_for(name),'w',0775) do |f|
        f.puts template_function(name)
      end
    end
  end
end
