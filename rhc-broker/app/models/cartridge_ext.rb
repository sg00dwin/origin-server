module OpenShift
  class Cartridge

    def usage_rates
      @rates ||= Rails.application.config.billing[:plans].inject([]) do |rates, (plan_name, plan_details)|
        cartridge_rate = plan_details[:usage_rates][:cartridge][self.name.to_sym] rescue nil
        unless cartridge_rate.nil?
          rate = {}
          rate["plan_id"] = plan_name
          cartridge_rate.each do |key, value|
            rate[key] = value
          end
          rates.push(rate)
        end
        rates
      end
    end

  end
end
