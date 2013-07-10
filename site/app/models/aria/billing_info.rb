module Aria
  class BillingInfo < Base

    class VatNumberValidator < ::ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        vat = Valvat(value)
        iso_country_code = vat.iso_country_code || "EU"
        is_valid = true

        if options[:match_country]
          iso_country_code = (record.send(options[:match_country]) || "").upcase
          is_valid = iso_country_code == vat.iso_country_code
        end

        is_valid = is_valid && vat.valid? && vat.exists?
        record.errors.add(attribute, "VAT number validation is currently unavailable") if is_valid == nil
        record.errors.add(attribute, "#{value} is not a valid #{iso_country_code} VAT number") if is_valid == false
      end
    end

    attr_aria :address1,
              :address2,
              :address3,
              :city,
              :region,
              :country,
              :zip,
              :first_name,
              :middle_initial,
              :last_name,
              :email,
              :taxpayer_id
    # Rails 3.0 requires all define_attribute_method calls to be together

    # Aria makes us explicitly unset values on update
    @@nullable = [:bill_middle_initial, :bill_address2, :bill_address3]

    @@region_save_map = Hash.new(['bill_locality','bill_state_prov']).merge({
      'US' => ['bill_state_prov','bill_locality'],
      'CA' => ['bill_state_prov','bill_locality'],
    })
    @@region_load_map ||= Hash.new('locality').merge({
      'US' => 'state',
      'CA' => 'state',
    })

    validates_presence_of :first_name,
                          :last_name,
                          :address1,
                          :city,
                          :country,
                          :zip
    validates_presence_of :region, :message => "State can't be blank", :if => :region_is_state?
    validates_presence_of :region, :message => "Region can't be blank", :unless => :region_is_state?

    validates_length_of :first_name, :maximum => 32
    validates_length_of :middle_initial, :maximum => 1
    validates_length_of :last_name, :maximum => 32
    validates_length_of :address1, :maximum => 100
    validates_length_of :address2, :maximum => 100
    validates_length_of :address3, :maximum => 100
    validates_length_of :city, :maximum => 32
    validates_length_of :country, :maximum => 2
    validates_length_of :zip, :maximum => 14
    validates_length_of :region, :maximum => 2, :if => :region_is_state? # From Aria.state_prov
    validates_length_of :region, :maximum => 32, :unless => :region_is_state? # From Aria.locality

    validates_inclusion_of :country, :in => Rails.configuration.allowed_countries.map(&:to_s), :message => "Unsupported country %{value}"

    validates :taxpayer_id, :vat_number => {:match_country => :vies_country}, :if => :vies_country, :allow_blank => true

    account_prefix :from => 'billing_',
                   :to => 'bill_',
                   :rename_to_save => {
                     'bill_zip' => 'bill_postal_cd',
                     'bill_middle_initial' => 'bill_mi',
                   },
                   :rename_to_load => {},
                   :rename_to_update => {
                     'bill_zip' => 'bill_postal_cd',
                   },
                   :no_prefix => ['taxpayer_id']

    #def tax_exempt?
    #  tax_exempt.present? and tax_exempt.to_i > 0
    #end

    def to_aria_attributes(action='save', attributes=@attributes)
      # Only allow saving taxpayer_id through the UI if we can validate it
      if vies_country.blank? and attributes.key?('taxpayer_id')
        attributes = attributes.dup
        attributes.delete('taxpayer_id')
      end
      super(action, attributes)
    end

    class << self
      def rename_to_save(hash)
        super(hash)
        (region_set_key, region_clear_key) = @@region_save_map[hash['bill_country']]
        hash[region_set_key] = hash.delete('bill_region')
      end

      def rename_to_update(hash)
        super(hash)

        (region_set_key, region_clear_key) = @@region_save_map[hash['bill_country']]
        hash[region_set_key] = hash.delete('bill_region')
        hash[region_clear_key] = '~'

        # Explicitly nil empty string fields within Aria
        @@nullable.each {|n| hash[n.to_s] = "~" if hash[n.to_s] == "" }

        # Special case for blanking taxpayer_id
        # Add to @@nullable once Aria ticket 15013-40073 is fixed
        hash['taxpayer_id'] = " " if hash['taxpayer_id'] == ""
      end

      def rename_to_load(hash)
        super(hash)
        hash['region'] = hash.delete(@@region_load_map[hash['country']])
      end
    end

    def full_name
      [first_name, middle_initial, last_name].map(&:presence).compact.join(' ')
    end
    def address
      [address1, address2, address3, location].map(&:presence).compact
    end
    def location
      [
        [city].map(&:presence).compact,
        [region, zip, country].map(&:presence).compact.join(' ')
      ].map(&:presence).compact.join(', ')
    end

    def self.test(opts={})
      new({
        :first_name => 'Test',
        :middle_initial => 'T',
        :last_name => 'User',
        :address1 => '12345 Happy Street',
        :city => 'Happyville',
        :country => 'US',
        :region => 'TX',
        :zip => '10001',
        :email => 'foo@example.com',
      }.merge(opts))
    end

    def to_key
      []
    end

    def vies_country= (vies_country)
      @vies_country = vies_country
    end
    def vies_country
      @vies_country
    end

    protected
      # A user without a billing address is invalid
      def self.persisted?(details)
        details.billing_address1.present?
      end

      # Used to determine how to validate :region
      def region_is_state?
        ['US', 'CA'].include? country
      end
  end
end
