module Cloud
  module Sdk
    class AuthService
      @cdk_auth_provider = Cloud::Sdk::AuthService
      
      def self.provider=(provider_class)
        @cdk_auth_provider = provider_class
      end
      
      def self.instance
        @cdk_auth_provider.new
      end
      
      def generate_broker_key(app)
        iv = app.name
        token = app.user.rhlogin
        [iv, token]
      end

      def login(request, params, cookies)
        if params['broker_auth_key'] && params['broker_auth_iv']
          return params['broker_auth_key']
        else
          data = JSON.parse(params['json_data'])          
          return data["rhlogin"]
        end
      end
    end
  end
end