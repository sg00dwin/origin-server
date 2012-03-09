require 'rubygems'
require 'digest/md5'

module StickShift::Broker
  class MongoAuthService < StickShift::AuthService

    def authenticate(request, login, password)
      begin
        auth_config = Rails.application.config.ss[:auth]
        ds = StickShift::MongoDataStore.new(auth_config[:mongo])
        encoded_password = Digest::MD5.hexdigest(Digest::MD5.hexdigest(password) + auth_config[:salt])
        hash = ds.find_one({"_id" => login})
        if hash && !hash.empty? && (hash["password"] == encoded_password)
          return {:username => login, :auth_method => :login}
        end
      rescue Exception => e
        Rails.logger.error "MongoAuthService::authenticate exception: #{e.message}"
      end
      return nil
    end

    def login(request, params, cookies)
      if params['broker_auth_key'] && params['broker_auth_iv']
        return {:username => params['broker_auth_key'], :auth_method => :broker_auth}
      else
        data = JSON.parse(params['json_data'])
        return authenticate(request, data['rhlogin'], params['password'])
      end
    end
  end
end
