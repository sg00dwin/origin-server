module Aria
  require_dependency 'aria/errors'
  require_dependency 'aria/client'
  require_dependency 'aria/user'
  require_dependency 'aria/date_time'
  require_dependency 'aria/methods'

  include Cacheable

  def self.method_missing(method, *args, &block)
    if Module.respond_to?(method)
      super
    else
      client.send(method, *args, &block)
    end
  end

  # Not expected to change over server process lifetime
  cache_method :get_virtual_datetime,          :expires_in => 1.hour
  cache_method :get_acct_no_from_user_id,      :expires_in => 1.hour
  cache_method :get_client_plans_basic,        :expires_in => 1.hour
  cache_method :get_client_plan_service_rates, :expires_in => 1.hour
  cache_method :get_client_plan_services,      :expires_in => 1.hour
  cache_method :get_client_plans_all,          :expires_in => 1.hour

  cache_method :get_supp_field_value
  cache_method :get_supp_field_values

  # Vary by 'acct_no', which is the first arg for all user-related methods
  USER_CACHE_KEY = lambda{ |method, acct_no, *args| [Aria.name, method, Aria::User.cache_key(acct_no), *args] }

  [
    # Usage
    :get_usage_history,
    :get_unbilled_usage_summary,

    # Invoices / statements / payments
    :get_acct_invoice_history,
    :get_acct_trans_history,
    :get_acct_statement_history,
    :get_acct_tax_exempt_status,
    :get_payments_on_invoice,
    :get_statement_for_invoice,
    :get_invoice_details,

    # Plans
    :get_queued_service_plans,
    :get_acct_plans_all
  ].each do |method_name|
    cache_method method_name, USER_CACHE_KEY.curry[method_name], :expires_in => 10.minutes
  end
    
  def self.available?(message='Aria is not available:')
    return false unless Rails.configuration.aria_enabled
    Aria.gen_random_string
    true
  rescue Aria::AuthenticationError, Aria::NotAvailable => e
    puts "#{message} (#{caller.find{ |s| not s =~ /\/lib\/aria[\.\/]/}}) #{e}"
    false
  end

  private
    def self.client
      @client ||= Aria::Client.new
    end
end
