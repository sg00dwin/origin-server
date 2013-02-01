class BillingObserver < ActiveModel::Observer
  observe OpenShift::Cartridge

  def get_cart_usage_rate(data)
    cartridge = data[:cart]
    plan_details = Rails.application.config.billing[:aria][:plans][:megashift]
    data[:rate] = plan_details[:usage_rates][:cartridge][cartridge.to_sym]
  end
end
