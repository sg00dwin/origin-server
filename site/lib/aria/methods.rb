module Aria
  module Methods

    def available?(message='Aria is not available:')
      Aria.gen_random_string
      true
    rescue Aria::AuthenticationError, Aria::NotAvailable => e
      puts "#{message} (#{caller.find{ |s| not s =~ /\/lib\/aria[\.\/]/}}) #{e}"
      false
    end

    def default_plan_no
      Rails.application.config.aria_default_plan_no
    end

    def get_client_plans_basic
      super.plans_basic
    end

    def get_acct_no_from_user_id(user_id)
      super(:user_id => user_id).acct_no
    end

    def get_acct_details_all(acct_no)
      super(:acct_no => acct_no)
    end
    def get_supp_field_values(acct_no, field_name)
      super(:acct_no => acct_no, :field_name => field_name).supp_field_values || []
    end
 end
end
