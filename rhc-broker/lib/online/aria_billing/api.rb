require 'rubygems'
require 'wddx'

module Express
  module AriaBilling
    class Api
      attr_accessor :ah, :url, :usage_type

      def initialize(access_info=nil)
        if access_info != nil
          # no-op
        elsif defined? Rails
          access_info = Rails.application.config.billing[:aria]
        else
          raise Exception.new("Aria Billing Api service is not initialized")
        end
        @url = access_info[:config][:url]
        @usage_type = access_info[:usage_type]
        @ah = Express::AriaBilling::ApiHelper.instance(access_info)
      end

      def self.instance
        Express::AriaBilling::Api.new
      end

      # NOTE: This method is only used for *Testing*
      def create_fake_acct(*args)
        result = get_response(@ah.create_fake_acct(*args), __method__)
        result.acct_no
      end

      # NOTE: This method is only used for *Testing*
      def update_acct_contact(*args)
        get_response_status(@ah.update_acct_contact(*args), __method__)
      end

      def update_acct_status(*args)
        get_response_status(@ah.update_acct_status(*args), __method__)
      end

      def userid_exists(*args)
        get_response_status(@ah.userid_exists(*args), __method__)
      end

      def get_user_id_from_acct_no(*args)
        result = get_response(@ah.get_user_id_from_acct_no(*args), __method__)
        result.user_id
      end

      def get_acct_no_from_user_id(*args)
        result = get_response(@ah.get_acct_no_from_user_id(*args), __method__)
        result.acct_no
      end

      def record_usage(*args) 
        get_response_status(@ah.record_usage(*args), __method__)
      end

      def get_usage_history(*args)
        usage_history = nil
        begin
          result = get_response(@ah.get_usage_history(*args), __method__)
          usage_history = result.data["usage_history_records"]
        rescue Express::AriaBilling::ErrorCodeException => e
          raise if e.error_code.to_s != "1008"
          usage_history = []
        end
        usage_history
      end

      def get_acct_plans_all(*args)
        result = get_response(@ah.get_acct_plans_all(*args), __method__)
        result.data["all_acct_plans"]
      end
      
      def get_acct_details_all(*args)
        result = get_response(@ah.get_acct_details_all(*args), __method__)   
        result.data
      end

      def update_master_plan(*args)
        begin
          get_response(@ah.update_master_plan(*args), __method__)
        rescue Express::AriaBilling::ErrorCodeException => e
          raise if e.error_code.to_s != "1034"
        end
        return true
      end

      def assign_supp_plan(*args)
        get_response_status(@ah.assign_supp_plan(*args), __method__)
      end

      def modify_supp_plan(*args)
        get_response_status(@ah.modify_supp_plan(*args), __method__)
      end

      def cancel_supp_plan(*args)
        get_response_status(@ah.cancel_supp_plan(*args), __method__)
      end

      def update_acct_supp_fields(*args)
        get_response_status(@ah.update_acct_supp_fields(*args), __method__)
      end

      private

      def send(request)
        begin
          return request.execute
        rescue RestClient::RequestTimeout, RestClient::ServerBrokeConnection, RestClient::SSLCertificateNotVerified => e
          raise Express::AriaBilling::Exception.new "Failed to access resource: #{e.message}"
        rescue RestClient::ExceptionWithResponse => e
          raise Express::AriaBilling::Exception.new "Exception: #{e.response}, #{e.message}"
        rescue Exception => e
          raise Express::AriaBilling::Exception.new "Failed to access resource: #{e.message}"
        end
        return nil
      end

      def convert_to_get_params(hash)
        raise Express::AriaBilling::Exception.new "Param input is NOT a hash" unless hash.kind_of?(Hash)
        param_str = ""
        hash.each do |k, v|
          param_str += "&" if param_str != ""
          v = URI.escape(v.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
          param_str += "#{k}=#{v}"
        end
        param_str
      end

      def get_response(hash, method_name, ret_output=true)
        end_point = @url + '?' + convert_to_get_params(hash)
        Rails.logger.debug "Aria Billing api request: #{end_point}"
        request = RestClient::Request.new(:url => end_point, :method => :get)
        wddx_response = send(request)
        response = WDDX.load(wddx_response)
        Rails.logger.debug "Aria Billing api response: #{response.inspect}"
        if response.error_code != 0 && ret_output
          raise Express::AriaBilling::ErrorCodeException.new("#{method_name} failed with error message: #{response.error_msg}", response.error_code)
        end
        if ret_output
          return response
        else
          return response.error_code == 0
        end
      end

      def get_response_status(hash, method_name)
        get_response(hash, method_name, false)
      end
    end
  end
end
