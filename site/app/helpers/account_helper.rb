# encoding: UTF-8

module AccountHelper
  include CountryHelper

  PlanUpgradeStepsCreate = [
    {
      :name => 'Plans',
      :link => 'account_plans_path',
    },
    {
      :name => 'Account and Billing',
    },
    {
      :name => 'Payment Information'
    },
    {
      :name => 'Review and Confirm',
      :link => 'new_account_plan_upgrade_path'
    }
  ]

  def plan_upgrade_steps(active, options={})
    wizard_steps(PlanUpgradeStepsCreate, active, options)
  end

  def tax_exempt_help_status
    community_base_url 'policy/tax-exemptions'
  end

  def customer_support_new_ticket_url
    "https://access.redhat.com/support/cases/new/"
  end

  def contact_customer_support_url
    "https://access.redhat.com/customerservice"
  end

  def bill_period_description(bill)
    recurring_dates = collapse_dates(bill.recurring_bill_from, bill.recurring_bill_thru, :year => true) if bill.has_recurring?
    usage_dates = collapse_dates(bill.usage_bill_from, bill.usage_bill_thru, :year => true) if bill.has_usage?

    if recurring_dates and usage_dates
      "Includes usage charges for #{usage_dates} and recurring charges for #{recurring_dates}"
    elsif recurring_dates
      "Includes recurring charges for #{recurring_dates}"
    elsif usage_dates
      "Includes usage charges for #{usage_dates}"
    end
  end

  def usage_amount_with_units(amount, units)
    amount = amount.round(1)
    amount = amount.round(0) if amount >= 10
    "#{number_with_delimiter(amount)} #{units.pluralize(amount)}"
  end

  def line_item_details(li, show_usage_rates=true)
    if li.tax?
    elsif li.usage?
      if show_usage_rates
        "#{usage_amount_with_units(li.units, li.units_label)} × #{number_to_user_currency(li.rate)}"
      else
        "#{usage_amount_with_units(li.units, li.units_label)}"
      end
    elsif li.recurring?
      if li.rate
        "#{number_to_user_currency(li.rate)} / month#{" (prorated)" if li.units != 1}"
      elsif li.total_cost < 0
        "Service Credit"
      end
    end
  end

  def dynamic_country_form
   !(Rails.configuration.respond_to?(:disable_dynamic_country_form) && Rails.configuration.disable_dynamic_country_form)
  end

end
