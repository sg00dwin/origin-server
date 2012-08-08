module Aria
  class PaymentMethod
    include ActiveModel::Serialization
    extend ActiveModel::Naming

    attr_accessor :cc_no, :cvv        # available only during set
    attr_accessor :cc_id              # available only on read
    attr_accessor :cc_exp_mm, :cc_exp_yyyy
    attr_accessor :inSessionId, :mode
    alias_attribute :session_id, :inSessionId

    def initialize(opts=nil, persisted=false)
      opts.each_pair{ |k,v| send("#{k}=", v) } if opts
      @persisted = persisted
    end

    def persisted?
      @persisted
    end

    def form_of_payment
      'CreditCard'
    end
    def client_no
      Aria.client_no
    end

    def self.test
      new(:cc_no => '4111111111111111', :cc_exp_mm => 12, :cc_exp_yyyy => 2015, :cvv => 111)
    end

    # NOTE: Only accounts with a credit card payment method will be considered
    #       persisted?.  All other payment methods are considered invalid.
    def self.from_account_details(account_details)
      account_details.attributes.inject(new(nil, account_details.pay_method == '1')) do |payment_method, (k,v)|
        method = :"#{k}="
        v = v.to_i if v.present? && ['cc_expire_mm','cc_expire_yyyy'].include?(k)
        payment_method.send(method, v) if method_defined? method
        payment_method
      end
    end

    protected
      # Only exposed for deserialization from account details
      alias_attribute :cc_expire_mm, :cc_exp_mm
      alias_attribute :cc_expire_yyyy, :cc_exp_yyyy
      alias_attribute :cc_suffix, :cc_no
  end
end
