require 'rubygems'
require 'json'

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
      
      def attributes
        return @attributes if @attributes
      
        @attributes = {}
        self.instance_variable_names.map {|name| name[1..-1]}.each do |name|
          next if name == 'attributes' or name == 'changed_attributes' or name == previously_changed
          @attributes[name] = nil
        end
        @attributes
      end
      
      def attributes=(hash)
        hash.each do |key,value|
          self.send("#{key}=",value)
        end
      end
      
      def save
        @previously_changed = changes
        @changed_attributes.clear
      end
    end
  end
end