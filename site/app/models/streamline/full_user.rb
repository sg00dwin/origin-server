module Streamline
  class FullUser
    include ActiveModel::Serialization
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    attr_accessor :greeting, :first_name, :last_name
    attr_accessor :title, :company
    attr_accessor :address1, :address2, :address3
    attr_accessor :city, :state, :country, :postal_code
    attr_accessor :phone_number, :email_subscribe
    attr_accessor :login, :password, :password_confirmation

    def initialize(opts=nil, persisted=false, from_streamline=false)
      opts.each_pair do |k,v|
        key = from_streamline ? attribute_map(k) : k
        if respond_to?("#{key}=")
          send("#{key}=", v)
        end
      end if opts
      @persisted = persisted
    end

    def errors
      @errors ||= ActiveModel::Errors.new(self)
    end

    def persisted?
      @persisted
    end

    def promote
      @persisted = true
    end

    def to_streamline_hash
      # This tells the streamline API that we're with the band.
      streamline_hash = { :secretKey => self.secret_key }
      self.all_attributes.each do |attr|
        streamline_hash[self.attribute_map(attr)] = self.send(attr)
      end
      streamline_hash
    end

    # Currently, the streamline promoteUser API accepts lowerCamelCase input arguments,
    # but emits lower_underscored error codes of the form:
    #
    #    <filed_name>_<condition>
    #
    # in addition to a few special cases:
    # * key_mismatch - this is a config error case that is raise()-worthy
    # * password_match_failure - this is handed by I18n lookup
    # * address_required - notable because it doesn't match the field it is meant for: address1
    #
    # This code will need to employ self.attribute_map if/when the streamline API error codes
    # are made internally consistent with the input args.
    def parse_json_errors(json)
      if json and json['errors']
        json['errors'].each do |error|
          # Call shenanigans on a bogus/missing secret key
          raise Streamline::PromoteInvalidSecretKey if error == 'key_mismatch'

          # Put together a basic error message for this code
          msg = I18n.t error, :scope => :streamline, :default => I18n.t(:unknown)

          # Check for a missing required field error
          if field_match = error.match(/(\w+)_required/)
            attr = field_match[1] == 'address' ? :address1 : field_match[1].to_sym
            errors.add(attr, 'is required')
            msg = errors.full_message(attr, 'is required')
          end

          # Adding to :base is important for errors.full_messages to generate
          # appropriate error messages
          errors.add(:base, msg)
        end
      end
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

    protected
      def all_attributes
        @all_attributes ||= [:greeting, :first_name, :last_name, :title, :company, :address1, :address2, :address3, :city, :state, :country, :postal_code, :phone_number, :email_subscribe, :login, :password, :password_confirmation]
      end

      def attribute_map(attr)
        # These attributes are lowerCamelCased in the Streamline API
        attr_map = [:first_name, :last_name, :phone_number, :email_subscribe, :postal_code, :password_confirmation]
        flipped_attr = attr.to_s.camelize(:lower).to_sym
        return flipped_attr if (attr_map.include?(attr) or attr_map.include?(flipped_attr))
        attr
      end

      def secret_key
        @secret_key ||= Rails.configuration.streamline[:user_info_secret]
      end
  end
end
