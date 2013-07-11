module Aria
  class ContactInfo < Base
    @@attribute_names = 'first_name', 'middle_initial', 'last_name', 'address1', 'address2', 'city', 'region', 'country', 'zip', 'email'

    @@region_key_map = Hash.new('locality').merge({ 'US' => 'state_prov', 'CA' => 'state_prov' })

    attr_aria *@@attribute_names.map(&:to_sym)

    # Aria makes us explicitly unset values on update
    @@nullable = [:middle_initial, :address2]

    @@region_save_map = Hash.new(['locality','state_prov']).merge({
      'US' => ['state_prov','locality'],
      'CA' => ['state_prov','locality'],
    })
    @@region_load_map ||= Hash.new('locality').merge({
      'US' => 'state_prov',
      'CA' => 'state_prov',
    })

    # Don't do validation of presence of attributes
    # 1) We create from billing_info, which will do the validation
    # or
    # 2) We create from streamline, and can't edit anything anyway

    # Do validate the country is allowed
    validates_inclusion_of :country, :in => Rails.configuration.allowed_countries.map(&:to_s), :message => "Unsupported country %{value}", :allow_blank => true

    account_prefix :from => '',
                   :to => '',
                   :rename_to_save => {
                     'zip' => 'postal_cd',
                     'middle_initial' => 'mi',
                   },
                   :rename_to_load => {
                     'alt_email' => 'email',
                     'mi' => 'middle_initial',
                     'postal_code' => 'zip',
                   },
                   :rename_to_update => {
                     'zip' => 'postal_cd',
                   },
                   :no_prefix => []

    def vies_country
      return country if country.present? and Rails.configuration.vies_countries.include?(country.to_sym)
    end

    class << self
      def rename_to_save(hash)
        super(hash)

        (region_set_key, region_clear_key) = @@region_save_map[hash['country']]
        hash[region_set_key] = hash.delete('region')
      end

      def rename_to_update(hash)
        super(hash)

        (region_set_key, region_clear_key) = @@region_save_map[hash['country']]
        hash[region_set_key] = hash.delete('region')
        hash[region_clear_key] = '~'

        # Explicitly nil empty string fields within Aria
        @@nullable.each {|n| hash[n.to_s] = "~" if hash[n.to_s] == "" }
      end

      def rename_to_load(hash)
        super(hash)
        hash['region'] = hash.delete(@@region_load_map[hash['country']])
      end

      def from_billing_info(billing_info)
        new(billing_info.attributes.slice(*@@attribute_names))
      end

      def from_full_user(full_user)
        attributes = full_user.attributes.slice(*@@attribute_names)
        attributes['region'] = full_user.state
        attributes['zip'] = full_user.postal_code
        new(attributes)
      end
    end

    protected
      # A user without a country is invalid
      def self.persisted?(details)
        details.country.present?
      end
  end
end
