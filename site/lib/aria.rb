module Aria
  require_dependency 'aria/errors'
  require_dependency 'aria/client'
  require_dependency 'aria/user'
  require_dependency 'aria/methods'

  include Cacheable

  def self.method_missing(method, *args, &block)
    if Module.respond_to?(method)
      super
    else
      client.send(method, *args, &block)
    end
  end

  cache_method :get_acct_no_from_user_id
  cache_method :get_supp_field_value
  cache_method :get_supp_field_values
  cache_method :get_client_plans_basic

  def self.available?(message='Aria is not available:')
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
