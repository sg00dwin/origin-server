module Aria
  class Coupon < Base
    define_attribute_method :coupon_code

    def blank?
      coupon_code.blank?
    end

    # Applies a coupon named "external<COUPON CODE>" to the user's account
    # Returns a success message if the coupon was already applied, or is successfully applied
    # Returns false with errors attached to the coupon_code field if the coupon wasn't applied
    def save(aria_user)
      begin
        success = Aria.apply_coupon_to_acct(aria_user.acct_no, "external#{coupon_code}".downcase).user_success_msg
        success = "Coupon was successfully applied" if success.blank?
        success
      rescue Aria::CouponExists => e
        "The coupon was already applied to your account"
      rescue Aria::CouponDoesNotExist
        errors.add(:coupon_code, "Invalid coupon code")
        false
      rescue Exception => e
        Rails.logger.error "Error applying coupon: #{e}\n#{e.backtrace.join("\n  ")}"
        errors.add(:coupon_code, "The coupon could not be applied")
        false
      end
    end
  end
end
