module Aria
  module User
    # mixins for Aria user integration

    def acct_no
      @acct_no ||= Aria.get_acct_no_from_user_id(user_id)
    end

    def create_session
      @session_id ||= Aria.set_session(:user_id => user_id)
    end

    def destroy_session
      Aria.kill_session(:session_id => @session_id) if @session_id
      @session_id = nil
    rescue InvalidSession
      nil
    end

    def has_valid_account?
      values = get_supplemental_values(:rhlogin)
      raise Aria::UserNoRHLogin, acct_no if values.empty?
      raise Aria::UserIdCollision, acct_no unless values.include?(login)
      true
    rescue AccountDoesNotExist
      false
    end

    def has_complete_account?
      return false unless has_valid_account?
      billing_info.valid?
    rescue AccountDoesNotExist
      false
    end

    def account_details
      @account_details ||= begin
        Aria.get_acct_details_all(acct_no)
      end
    end

    def billing_info
      @billing_info ||= begin
        Aria::BillingInfo.from_account_details(account_details)
      rescue AccountDoesNotExist
        Aria::BillingInfo.new
      end
    end

    def has_valid_payment_method?
      account_details.status_cd.to_i > 0
    end

    def payment_method
      nil
    end

    def tax_exempt
      @tax_exempt ||= (get_supplemental_value(:tax_exempt) || 0).to_i
    end
    def tax_exempt?
      tax_exempt > 0
    end

    def create_account(opts=nil)
      params = default_account_params
      opts.each_pair do |k,v|
        if v.respond_to? :to_aria_attributes
          params.merge!(v.to_aria_attributes)
        else
          params[k] = v
        end
      end if opts
      Aria.create_acct_complete(params)
      true
    rescue Aria::AccountExists
      raise
    rescue Aria::Error => e
      errors.add(:base, e.to_s)
      false
    end

    def update_account(opts)
      params = HashWithIndifferentAccess.new
      opts.each_pair do |k,v|
        if v.respond_to? :to_aria_attributes
          params.merge!(v.to_aria_attributes)
        else
          params[k] = v
        end
      end
      Aria.update_acct_complete(acct_no, params)
      @billing_info = nil
      @account_details = nil
      @tax_exempt = nil
      true
    rescue Aria::Error => e
      errors.add(:base, e.to_s)
      false
    end

    def set_session_redirect(url)
      set_reg_uss_params('redirecturl', url)
    end

    private
      def user_id
        Digest::MD5::hexdigest(login)
      end
      def random_password
        ActiveSupport::SecureRandom.base64(16)[0..12].gsub(/[^a-zA-Z0-9]/,'_') # Max allowed Aria limit
      end

      def get_supplemental_value(field)
        get_supplemental_values(field).first
      end
      def get_supplemental_values(field)
        Aria.get_supp_field_values(acct_no, field)
      end

      # Checks whether the basic Aria account exists, but not whether
      # it is valid.
      def has_account?
        Aria.userid_exists user_id
        true
      rescue AccountDoesNotExist
        false
      end

      def set_reg_uss_params(name, value)
        Aria.set_reg_uss_params({
          :session_id => create_session,
          :param_name => name,
          :param_val => value,
        })
      end

      def default_account_params
        HashWithIndifferentAccess.new({
          :userid => user_id,
          :status_cd => 0,
          :master_plan_no => Aria.default_plan_no,
          :password => random_password,
          :test_acct_ind => Rails.application.config.aria_force_test_users ? 1 : 0,
          :supplemental => {:rhlogin => login, :tax_exempt => 0},
        })
      end
  end
end
