module OpenShift
  class Cartridge

    def usage_rates
      rates = []
      if self.is_premium?
        Rails.application.config.billing[:aria][:plans].each do |plan_name, plan_details|
          cartridge_rate = plan_details[:usage_rates][:cartridge][self.name.to_sym] rescue nil
          unless cartridge_rate.nil?
            rate = {}
            rate["plan_id"] = plan_name
            cartridge_rate.each do |key, value|
              rate[key] = value
            end
            rates.push(rate)
          end
        end
      end
      rates
    end

  end
end
