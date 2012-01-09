require 'rubygems'
require 'json'
require 'active_model'

module Cloud
  module Sdk
    class Model
      extend ActiveModel::Naming        
      include ActiveModel::Validations      
      include ActiveModel::Serializers::JSON
      self.include_root_in_json = false
      include ActiveModel::Serializers::Xml
      include ActiveModel::Dirty
      include ActiveModel::Observing
      include ActiveModel::AttributeMethods
      include ActiveModel::Observing
      include ActiveModel::Conversion
      
      @@primary_key = :uuid
      @@excludes_attributes = []
      
      def initialize
        @persisted = false
        @new_record = true
        @deleted = false
      end
      
      def new_record?
        @new_record
      end
      
      def persisted?
        @persisted
      end
      
      def deleted?
        @deleted
      end
      
      def self.gen_uuid
        File.open("/proc/sys/kernel/random/uuid", "r") do |file|
          file.gets.strip.gsub("-","")
        end
      end
      
      def self.attr_reader(*accessors)
        define_attribute_methods accessors
        
        accessors.each do |m|
          define_method(m) do  
            instance_variable_get("@#{m}")
          end
        end
      end
      
      def self.attr_writer(*accessors)
        define_attribute_methods accessors
        
        accessors.each do |m|
          class_eval <<-EOF
            def #{m}=(val)
              #{m}_will_change! unless @#{m} == val
              instance_variable_set("@#{m}",val)
            end
          EOF
        end
      end
      
      def self.attr_accessor(*accessors)
        attr_reader(*accessors)
        attr_writer(*accessors)
      end
      
      def self.primary_key(var_name)
        @primary_key = var_name
      end
      
      def self.exclude_attributes(*attributes)
        @excludes_attributes = [] unless @excludes_attributes
        @excludes_attributes += attributes
      end
      
      def attributes
        #return @attributes if @attributes
      
        @attributes = {}
        self.instance_variable_names.map {|name| name[1..-1]}.each do |name|
          next if ['attributes', 'changed_attributes', 'previously_changed', 'persisted', 'new_record', 'deleted', 'errors', 'validation_context'].include? name
          next if self.class.excludes_attributes.include? name.to_sym
          @attributes[name] = nil
        end
        @attributes
      end
      
      def attributes=(hash)
        return nil unless hash
        
        hash.each do |key,value|
          self.send("#{key}=",value)
        end
      end
      
      def reset_state
        @new_record = false
        @persisted = true
        @deleted = false
        @changed_attributes.clear if @changed_attributes
      end
      
      def self.excludes_attributes
        @excludes_attributes = [] unless @excludes_attributes
        @excludes_attributes
      end
      
      protected
      
      def self.pk
        @primary_key
      end
    end
  end
end