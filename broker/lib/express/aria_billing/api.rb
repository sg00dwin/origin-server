require 'rubygems'
require 'wddx'

module Express
  module AriaBilling
    class Api
      attr_accessor :url, :auth_key, :client_no, :usage_type

      def initialize(access_info = nil)
        if access_info != nil
          # no-op
        elsif defined? Rails
          access_info = Rails.application.config.billing[:aria]
        else
          raise Exception.new("Aria Billing Api service is not inilialized")
        end
        @url = access_info[:config][:url]
        @auth_key = access_info[:config][:auth_key]
        @client_no = access_info[:config][:client_no]
        @usage_type = access_info[:usage_type]
      end

      def self.instance
        Express::AriaBilling::Api.new
      end

      def userid_exists(user_id)
        request = {
          'user_id' => user_id,
          'client_no' => @client_no,
          'auth_key' => @auth_key,
          'rest_call' => "userid_exists"
        }
        get_response(request)
      end

      def get_acct_no_from_userid(user_id)
        request = {
          'user_id' => user_id,
          'client_no' => @client_no,
          'auth_key' => @auth_key,
          'rest_call' => "get_acct_no_from_userid"
        }
        #TODO: return only acct_no
        get_response(request)
      end

      def record_usage(user_id=nil, acct_no=nil, 
                            usage_type=@usage_type[:small], usage_units=1)
        raise Exception.new "user_id or acct_no must be valid" if !user_id && !acct_no
        request = {
          'usage_units' => usage_units,
          'usage_date' => Time.now.strftime("%Y-%m-%d %H:%M:%S"),
          'usage_type' => usage_type,
          'client_no' => @client_no,
          'auth_key' => @auth_key,
          'rest_call' => "record_usage"
        }
        user_id ? request['userid']=user_id : request['acct_no']=acct_no
        get_response(request)
      end

      def get_usage_history(acct_no, specified_usage_type_no=nil,
                                 date_range_start=(Time.now-24*60*60).strftime("%Y-%m-%d"),
                                 date_range_end=Time.now.strftime("%Y-%m-%d"))
        request = {
          'acct_no' => acct_no,
          'specified_usage_type_no' => specified_usage_type_no,
          'date_range_start' => date_range_start,
          'date_range_end' => date_range_end,
          'client_no' => @client_no,
          'auth_key' => @auth_key,
          'rest_call' => "get_usage_history"
        }
        get_response(request)
      end

      private

      def send(request)
        begin
          return request.execute
        rescue RestClient::RequestTimeout, RestClient::ServerBrokeConnection, RestClient::SSLCertificateNotVerified => e
          raise Exception.new "Failed to access resource: #{e.message}"
        rescue RestClient::ExceptionWithResponse => e
          raise Exception.new "Exception: #{e.response}, #{e.message}"
        rescue Exception => e
          raise Exception.new "Failed to access resource: #{e.message}"
        end
        return nil
      end

      def convert_to_get_params(hash)
        raise Exception.new("Param input is NOT a hash") unless hash.kind_of?(Hash)
        param_str = ""
        hash.each do |k, v|
          param_str += "&" if param_str != ""
          v = URI.escape(v.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
          param_str += "#{k}=#{v}"
        end
        param_str
      end

      def get_response(hash)
        end_point = @url + '?' + convert_to_get_params(hash)
        #puts end_point
        request = RestClient::Request.new(:url => end_point, :method => :get)
        wddx_response = send(request)
        response = WDDX.load(wddx_response)
        Rails.logger.debug "Aria Billing api response: #{response.inspect}"
        response
      end
    end
  end
end
