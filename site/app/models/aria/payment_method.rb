module Aria
  class PaymentMethod
    include ActiveModel::Serialization
    extend ActiveModel::Naming

    attr_accessor :cc_no, :cc_exp_mm, :cc_exp_yyyy, :cvv
    attr_accessor :inSessionId, :mode
    alias_attribute :session_id, :inSessionId

    def initialize(opts=nil)
      opts.each_pair{ |k,v| send("#{k}=", v) } if opts
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

    def self.set_mode_website_new_payment(redirect_url)
      Aria.set_reg_uss_config_params('direct_post_website_new_payment', {
        :redirecturl => redirect_url,
        :do_cc_auth => 1,
        :min_auth_threshold => 0,
        :change_status_on_cc_auth_success => 1,
        :status_on_cc_auth_success => 1,
        :change_status_on_cc_auth_failure => 1,
        :status_on_cc_auth_failure => -1,
      })
      'website_new_payment'
    end
  end
end
