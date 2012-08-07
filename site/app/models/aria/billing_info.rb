module Aria
  class BillingInfo < Base
    attr_aria :address1,
              :address2,
              :address3,
              :city,
              :state,
              :country,
              :zip,
              :first_name,
              :middle_initial,
              :last_name
    # Rails 3.0 requires all define_attribute_method calls to be together

    validates_presence_of :address1,
                          :city,
                          :state,
                          :country,
                          :zip

    account_prefix :from => 'billing_',
                   :to => 'bill_',
                   :rename_to_save => {
                     'bill_zip' => 'bill_postal_cd',
                     'bill_state' => 'bill_state_prov',
                     'bill_middle_initial' => 'bill_mi',
                   }

    #def tax_exempt?
    #  tax_exempt.present? and tax_exempt.to_i > 0
    #end

    def self.test
      new({
        :address1 => '12345 Happy Street',
        :city => 'Happyville',
        :country => 'US',
        :state => 'TX',
        :zip => '10001',
      })
    end

    protected
      # A user without a billing address is invalid
      def self.persisted?(details)
        details.billing_address1.present?
      end
  end
end
