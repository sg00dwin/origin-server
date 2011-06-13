require 'openshift/blacklist'
require 'openshift/server'


module Libra
  module Util

    Maxdlen = 16

    def self.get_cartridge_types(sep=', ')
      i = 0
      carts = get_cart_list
      carts.join(sep)
    end

    def self.get_cartridge(type)
      carts = get_cart_list
      if carts.include?(type)
        return type
      end
      return nil
    end

    def self.get_cart_list
      server = Server.find_available
      carts = []
      server.carts.split('|').each do |cart|
          carts << cart unless Blacklist.ignore_cart?(cart)
      end
      return carts
    end

    # Invalid chars (") ($) (^) (<) (>) (|) (%) (/) (;) (:) (,) (\) (*) (=) (~)
    def self.check_rhlogin(rhlogin)
      if rhlogin && rhlogin.length < 6
        #puts 'RHLogin must be at least 6 characters'
        return false
      elsif rhlogin =~ /["\$\^<>\|%\/;:,\\\*=~]/
        #puts 'RHLogin may not contain any of these characters: (\") ($) (^) (<) (>) (|) (%) (/) (;) (:) (,) (\) (*) (=) (~)'
        return false
      else
        return true
      end
    end

    def self.check_app(app)
      check_field(app, 'application', Maxdlen)
    end

    def self.check_namespace(namespace)
      check_field(namespace, 'namespace', Maxdlen)
    end

    def self.check_field(field, type, max=0)
      if field
        if field =~ /[^0-9a-zA-Z]/
          #puts "#{type} contains non-alphanumeric characters!"
          return false
        end
        if Blacklist.in_blacklist?(field)
          return false
        end
        if max != 0 && field.length > Maxdlen
          #puts "maximum #{type} size is #{Maxdlen} characters"
          return false
        end
      else
        #puts "#{type} is required"
        return false
      end
      true
    end

  end
end
