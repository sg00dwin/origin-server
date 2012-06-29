module Aria

  module User
    # mixins for Aria user integration

    def acct_no
      @acct_no ||= Aria.get_acct_no_from_user_id(user_id)
    end

    def has_valid_account?
      values = Aria.get_supp_field_values(acct_no, 'RHLogin')
      raise Aria::UserNoRHLogin, acct_no if values.empty?
      raise Aria::UserIdCollision, acct_no unless values.include?(rhlogin)
      true
    rescue AccountDoesNotExist
      false
    end

    def has_payment_method?
      false
    end

    def payment_method
      nil
    end

    def create_account
      Aria.create_acct_complete({
        :userid => user_id,
        :master_plan_no => Aria.default_plan_no,
        :password => random_password,
        :supp_field_names => 'RHLogin',
        :supp_field_values => rhlogin,
      })
      true
    rescue Aria::Error => e
      errors.add(:base, e.to_s)
      false
    end

    private
      def user_id
        Digest::MD5::hexdigest(login)
      end
      def random_password
        ActiveSupport::SecureRandom.base64(16)[0..12] # Max allowed Aria limit
      end
  end
end
