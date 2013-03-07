module Streamline
  class FullUser
    include ActiveModel::Serialization
    include ActiveModel::Validations
    include ActiveModel::Conversion
    include Streamline::Attributes
    extend ActiveModel::Naming

    attribute_method_suffix '='
    attr_reader :attributes

    # Set up the attributes that are the same between this object and the Streamline API
    attr_streamline :greeting, :title, :company, :address1, :address2, :address3, :city, :state, :country, :login, :password

    # Set up the attributes that are different between this object and the Streamline API
    [:first_name, :last_name, :phone_number, :email_subscribe, :postal_code, :password_confirmation].each do |attr|
      attr_streamline attr, :as => attr.to_s.camelize(:lower).to_sym
    end

    def initialize(opts=nil, persisted=false)
      @attributes = {}
      opts.each_pair do |k,v|
        if respond_to?("#{k}=")
          send("#{k}=", v)
        end
      end if opts
      @persisted = persisted
    end

    def id
      @attributes[:login]
    end

    def errors
      @errors ||= ActiveModel::Errors.new(self)
    end

    def persisted?
      @persisted
    end

    def promote(user)
      if user.promote(to_streamline_hash)
        @persisted = true
      else
        user.errors.each do |attribute,error|
          self.errors.add(attribute, error)
        end
      end
      persisted?
    end

    def self.test
      new({
        :greeting => 'Mr.',
        :first_name => 'Joe',
        :last_name => 'Somebody',
        :phone_number => '9191111111',
        :company => 'Red Hat, Inc.',
        :address1 => '12345 Happy Street',
        :city => 'Happyville',
        :country => 'US',
        :state => 'TX',
        :postal_code => '10001',
      })
    end

    private
      def attribute=(attr, value)
        @attributes[attr] = value
      end
      def attribute(attr)
        @attributes[attr]
      end
  end
end
