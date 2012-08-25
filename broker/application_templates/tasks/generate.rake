#!/usr/bin/env ruby

namespace :descriptors do
  desc "Create applications and retrieve their descriptors"
  task :generate do
    client = login
    domain = client.domains.first

    unless domain
      puts "Must have a domain to create applications...will only use existing descriptors"
    end

    deploy_opts = application_templates.map do |template|
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
      elsif !domain
        puts "No descriptor exists, and no domain exists, so we cannot create...skipping"
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

      opts[:metadata] =
        opts[:metadata].inject({}){|h,(k,v)| h[k] = v.kind_of?(String) ? v.strip : v; h }

      # Save script information for deploy script
      desc = Hash[
        YAML.load_file(template.descriptor).map do |k,v|
          [k,v.is_a?(BSON::OrderedHash) ? {} : v]
        end
      ].to_yaml

      {
        :name => name,
        :script => template.template_function(false),
        :metadata => JSON.pretty_generate(opts[:metadata]),
        :descriptor => desc
      }
    end.compact.sort_by{|x| x[:name] }

    FileUtils.cp "#{deploy_script}.template", deploy_script

    File.open(deploy_script,'a') do |f|
      f.write YAML.dump deploy_opts
    end
  end
end
