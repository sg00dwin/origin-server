class ExpressUserinfo
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Serialization
  extend ActiveModel::Naming
  
  include ExpressApi
  
  attr_accessor :app_info, :uuid, :ssh_key, :rhc_domain, :namespace, :messages
  
  validates_presence_of :rhlogin
  validates :password, :length => {:minimum => 6} 
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
  
  # Fetches information and sets class attributes
  # returns false if api error occured
  def establish
    data = {:rhlogin => @rhlogin}
    data[:password] = @password unless @password.nil? # password is optional
    json_data = ActiveSupport::JSON.encode(data)
    http_post @@userinfo_url, json_data do |response|
      Rails.logger.debug('response received from api')
      #set messages
      @messages = response[:result][:messages]
      #test exit code for success/failure
      if response[:exit_code] == 0
        #success! > set attributes
        @app_info = response[:result][:app_info]
        response[:result][:user_info].each do |key, value|
          unless key == :rhlogin
            send("#{name}=", value)
          end #end unless
        end #end userinfo block
      else
        #failure! boo
        false
      end #end if
    end #end response block
  end #end function
  
end
