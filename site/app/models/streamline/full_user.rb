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
      opts.each_pair do |k,v|
        send("#{k}=", v) if respond_to?("#{k}=")
      end if opts
      @persisted = persisted
    end

    def persisted?
      @persisted
    end

    def self.test
      new({
        :first_name => 'Joe',
        :last_name => 'Somebody',
        :phone => '919-111-1111',

        :address1 => '12345 Happy Street',
        :city => 'Happyville',
        :country => 'US',
        :state => 'TX',
        :zip => '10001',
      })
    end
  end
end
