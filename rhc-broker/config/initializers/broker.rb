CloudUserObserver.instance
DomainObserver.instance
#customizations to models
require 'cloud_user_ext'
require 'usage_ext'
require 'cartridge_ext'

# Extend mcollective with online specific extensions
require File.expand_path('../../lib/online/broker/mcollective_ext', File.dirname(__FILE__))


# if this is not production, randomize the uuid
if defined?(Rails) and (not Rails.env.production?)
  # Don't know what the load order is, but district doesn't seem to have been loaded
  require 'district'
  
  class Gear
    alias :old_initialize :initialize
    
    def initialize(attrs = nil, options = nil)
      attrs = {} if attrs.nil?
      
      # if the original app and gear UUID were meant to be the same, make sure they are still the same
      # this is true for the first gear, since app UUID is used to ssh into the gear
      if attrs[:custom_id] && attrs[:group_instance] && attrs[:custom_id] == attrs[:group_instance].application.uuid
        attrs[:uuid] = attrs[:group_instance].application.uuid
      else
        rand_ctr = rand(1..3)
        case rand_ctr
        when 1
          # randomize to 24 character BSON ObjectId
          attrs[:uuid] = BSON::ObjectId.new.to_s
        when 2
          # randomize to 32 character UUID
          attrs[:uuid] = UUIDTools::UUID.timestamp_create.to_s.gsub('-', '').strip
        else
          # randomize to a 24 digit numeric value
          attrs[:uuid] = rand(1e23..1e24-1).to_i.to_s
        end
      end

      # call the original method
      old_initialize(attrs, options)
    end
  end

  class Application
    alias :old_initialize :initialize
    
    def initialize(attrs = nil, options = nil)
      attrs = {} if attrs.nil?
      rand_ctr = rand(1..3)
      case rand_ctr
      when 1
        # randomize to 24 character BSON ObjectId
        attrs[:uuid] = BSON::ObjectId.new.to_s
      when 2
        # randomize to 32 character UUID
        attrs[:uuid] = UUIDTools::UUID.timestamp_create.to_s.gsub('-', '').strip
      else
        # randomize to a 24 digit numeric value
        attrs[:uuid] = rand(1e23..1e24-1).to_i.to_s
      end

      # call the original method
      old_initialize(attrs, options)
    end
  end

  class District
    alias :old_initialize :initialize
    
    def initialize(attrs = nil, options = nil)
      attrs = {} if attrs.nil?
      rand_ctr = rand(1..3)
      case rand_ctr
      when 1
        # randomize to 24 character BSON ObjectId
        attrs[:uuid] = BSON::ObjectId.new.to_s
      when 2
        # randomize to 32 character UUID
        attrs[:uuid] = UUIDTools::UUID.timestamp_create.to_s.gsub('-', '').strip
      else
        # randomize to a 24 digit numeric value
        attrs[:uuid] = rand(1e23..1e24-1).to_i.to_s
      end

      # call the original method
      old_initialize(attrs, options)
    end
  end
end
