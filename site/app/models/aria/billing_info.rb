module Aria
  class BillingInfo < Base
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
              :currency_cd
    # Rails 3.0 requires all define_attribute_method calls to be together

    validates_presence_of :address1,
                          :city,
                          :country,
                          :zip
    validates_presence_of :region, :message => "State can't be blank", :if => :region_is_state?
    validates_presence_of :region, :message => "Region can't be blank", :unless => :region_is_state?
    validates_presence_of :currency_cd, :message => "Currency can't be blank", :if => :can_change_currency?

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

    account_prefix :from => 'billing_',
                   :to => 'bill_',
                   :rename_to_save => {
                     'bill_zip' => 'bill_postal_cd',
                     'bill_middle_initial' => 'bill_mi',
                   },
                   :rename_to_load => {},
                   :no_rename_to_update => ['bill_middle_initial'],
                   :no_prefix => ['currency_cd']

    #def tax_exempt?
    #  tax_exempt.present? and tax_exempt.to_i > 0
    #end

    class << self
      def rename_to_save(hash, action='save')
        super(hash, action)
        @save_map ||= Hash.new(['bill_locality','bill_state_prov']).merge({
          'US' => ['bill_state_prov','bill_locality'],
          'CA' => ['bill_state_prov','bill_locality'],
        })
        (new_field, clear_field) = @save_map[hash['bill_country']]
        hash[new_field] = hash['bill_region']
        # This explicitly nils the unused field within Aria
        hash[clear_field] = '~'
        hash.delete('bill_region')
      end

      def rename_to_load(hash)
        super(hash)
        @load_map ||= Hash.new('locality').merge({
          'US' => 'state',
          'CA' => 'state',
        })
        load_key = @load_map[hash['country']]
        hash['region'] = hash[load_key]
        hash.delete(load_key)
      end
    end

    def can_change_currency?
      !@persisted
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
      ].compact.join(', ')
    end

    def self.test
      new({
        :address1 => '12345 Happy Street',
        :city => 'Happyville',
        :country => 'US',
        :region => 'TX',
        :zip => '10001',
        :currency_cd => 'usd'
      })
    end

    def to_key
      []
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
