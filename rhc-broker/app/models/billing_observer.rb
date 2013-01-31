class BillingObserver < ActiveModel::Observer
  observe OpenShift::Cartridge

  def get_cart_pricing(data)
    cartridge = data[:cart]
    plan_details = Rails.application.config.billing[:aria][:plans][:megashift]
    data[:price] = plan_details[:charges][:cartridge][cartridge]
  end
end
