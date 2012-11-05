module Streamline
  class FullUser
    include ActiveModel::Serialization
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    attr_accessor :first_name, :last_name
    attr_accessor :address1, :address2, :address3
    attr_accessor :city, :state, :country, :zip
    attr_accessor :phone

    def initialize(opts=nil, persisted=false)
      @attributes = {}
      opts.each_pair do |k,v|
        if respond_to?("#{k}=")
          send("#{k}=", v)
          @attributes[k] = v
        end
      end if opts
      @persisted = persisted
    end

    def persisted?
      @persisted
    end

    def promote
      @persisted = true
    end

    def to_api
      arg_map = {
        :first_name => :firstName,
        :last_name => :lastName,
        :zip => :postalCode,
        :phone => :phoneNumber
      }

      new_args = {}
      @attributes.each_pair do |key,value|
        new_key = arg_map.has_key?(key) ? arg_map[key] : key
        new_args[new_key] = value
      end
      new_args
    end

    def self.test
      new({
        :first_name => 'Joe',
        :last_name => 'Somebody',
        :phone => '9191111111',

        :address1 => '12345 Happy Street',
        :city => 'Happyville',
        :country => 'US',
        :state => 'TX',
        :zip => '10001',
      })
    end
  end
end
