require 'rubygems'
require 'thor'
require 'net/http'
require 'net/https'
require 'date'
require 'json'
require 'cgi'

module OpenShift
  module SauceLabs

    #TODO: fetch from Sauce Labs service
    USERS =  %w(openshift_ci flindiak dmcphers)
    PLAN_MINUTES = 4000

    def sauce_usage(options)
      total = 0
      today = Date.today
      month_begin = Date.new(today.year, today.month, 1)
      month_end = Date.new(today.year, today.month + 1, 1) - 1

      creds = {
        :username => options[:sauce_username] || SAUCE_USER,
        :access_key => options[:sauce_access_key] || SAUCE_SECRET
      }      

      USERS.each do |u|
        mins = query_usage creds, u, month_begin, month_end
        puts "#{u}: #{mins}" if options[:verbose]
        total = total + mins
      end

      pct = total*100.0 / PLAN_MINUTES

      {
        :used => total,
        :quota => PLAN_MINUTES,
        :percentage => pct,
        :overage => (pct >= 100.0)
      }
    end

    private

    def sauce_json(creds, path, params={})
      query = to_query(params)

      req = Net::HTTP::Get.new("#{path}?#{query}")
      req.basic_auth creds[:username], creds[:access_key]

      http = Net::HTTP.new('saucelabs.com', 443)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      res = http.request(req)

      unless res.body and !res.body.empty?
        raise Exception
      end

      data = JSON.parse res.body
      raise Exception, data['error'] if data['error']
      data
    end

    def query_usage(credentials, username, start_date=nil, end_date=nil)
      mins = 0
      fmt = "%Y-%m-%d"

      params = {}
      params['start'] = start_date.strftime(fmt) if start_date
      params['end'] = end_date.strftime(fmt) if end_date

      data = sauce_json(credentials, "/rest/v1/users/#{username}/usage", params)
      data['usage'].each do |p|
        d = Date.parse(p[0])
        mins = mins + p[1][0]
      end
      mins
    end

    def to_query(params)
      params.collect { |k,v| "#{k}=#{CGI::escape(v.to_s)}" }.join('&')
    end

  end
end
