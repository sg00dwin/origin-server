#!/usr/bin/env ruby

namespace :descriptors do
  desc "Create applications and retrieve their descriptors"
  task :generate do
    client = login
    domain = client.domains.first

    unless domain
      puts "Must have a domain to create applications...exiting"
      exit
    end

    application_templates.each do |template|
      name = template.name
      puts "Checking template for #{name}"
      target = template.target

      # Skip if we haven't specified a target
      unless File.exists?(target)
        puts "no target specified, skipping"
        next
      end

      # load options from target
      opts = YAML.load_file(target)
      # Check to see if descriptor already exists
      descriptor = template.descriptor
      if File.exists?(descriptor)
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
        template.save(:descriptor,app.descriptor)

        # Destroy app
        destroy_app(app)
      end

      # Dump the metadata JSON
      template.save(:metadata,JSON.pretty_generate(opts[:metadata]))
    end
  end
end
