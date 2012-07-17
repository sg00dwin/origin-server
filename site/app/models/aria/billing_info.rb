module Aria
  class BillingInfo < Base
    attr_aria :address1,
              :address2,
              :address3,
              :city,
              :state,
              :country,
              :zip,
              # 0 or nil, not exempt
              # 1, requested exemption
              # 2, granted exemption
              :tax_exempt,
              # questionable
              :first_name, :last_name
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
                   },
                   :supplemental => :tax_exempt

    def tax_exempt?
      tax_exempt.present? and tax_exempt.to_i > 0
    end

    def self.test
      new({
        :address1 => '12345 Happy Street',
        :city => 'Happyville',
        :country => 'US',
        :state => 'TX',
        :zip => '10001',
      })
    end
  end
end
