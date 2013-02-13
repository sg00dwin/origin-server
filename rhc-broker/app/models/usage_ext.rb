require 'usage'
class Usage

  def get_usage_rate(plan_id)
    usage_rates, usage_rate = nil, nil

    # Get the usage rates for the user's billing plan
    user_plan = plan_id.nil? ? Rails.configuration.billing[:aria][:default_plan] : plan_id.to_sym
    if defined?(Rails) && Rails.configuration.billing
      usage_rates = Rails.configuration.billing[:aria][:plans][user_plan][:usage_rates] rescue nil
    end
    
    if usage_rates
      case self.usage_type
      when UsageRecord::USAGE_TYPES[:gear_usage]
        usage_rate = usage_rates[:gear][self.gear_size.to_sym]
      when UsageRecord::USAGE_TYPES[:addtl_fs_gb]
        usage_rate = usage_rates[:storage][:gigabyte]
      when UsageRecord::USAGE_TYPES[:premium_cart]
        usage_rate = usage_rates[:cartridge][self.cart_name.to_sym]
      end
    end
    usage_rate
  end

end