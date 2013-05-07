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

  def line_item_details(li)
    if li.tax?
    elsif li.usage?
      "#{number_with_precision(li.units, :precision => (li.units < 1 ? 2 : 0))} @ #{number_to_user_currency(li.rate)} / #{li.units_label}"
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

  def collapse_dates(date1, date2, opts = {})
    year = opts[:year] ? ", %Y " : ""
    day1 = opts[:ordinalize] ? ActiveSupport::Inflector.ordinalize(date1.day) : date1.day
    day2 = opts[:ordinalize] ? ActiveSupport::Inflector.ordinalize(date2.day) : date2.day
    if date1.year == date2.year and date1.month == date2.month
      date1.strftime("%B #{day1}–#{day2}#{year}")
    elsif date1.year == date2.year
      date1.strftime("%B #{day1}") + " – " + date2.strftime("%B #{day2}#{year}")
    else
      date1.strftime("%B #{day1}#{year}") + " – " + date2.strftime("%B #{day2}#{year}")
    end
  end

end
