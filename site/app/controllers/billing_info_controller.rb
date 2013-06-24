class BillingInfoController < ConsoleController
  include BillingAware

  before_filter :authenticate_user!
  before_filter :user_can_upgrade_plan!

  def edit
    @billing_info = current_aria_user.billing_info
    @show_vat = current_aria_user.contact_info.vies_country.present?
  end

  def update
    @billing_info = Aria::BillingInfo.new(params[:aria_billing_info][:aria_billing_info], current_aria_user.has_account?)

    # Tell the billing info which country to use to validate the VAT ID
    @billing_info.vies_country = current_aria_user.contact_info.vies_country
    @show_vat = current_aria_user.contact_info.vies_country.present?

    redirect_to next_path and return if current_aria_user.update_account(:billing_info => @billing_info)
    current_aria_user.errors[:base].each { |e| @billing_info.errors[:base] << e }
    render :edit
  end

  def next_path
    account_path
  end

  def previous_path
    next_path
  end

  protected
    def active_tab
      :account
    end
end
