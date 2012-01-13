class ExpressUserinfo
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Serialization
  extend ActiveModel::Naming
  
  include ExpressApi
  
  attr_accessor :app_info, :uuid, :ssh_key, :key_type, :rhc_domain, :namespace, :messages
  
  validates_presence_of :rhlogin
  validates :password, :length => {:minimum => 6},
                       :allow_blank => true
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
  
  # Fetches information and sets class attributes
  # returns false if api error occured
  def establish
    data = {:rhlogin => @rhlogin}
    json_data = ActiveSupport::JSON.encode(data)
    begin
      http_post @@userinfo_url, json_data, true do |response|
        Rails.logger.debug("response received from api : #{response.inspect}")
        #set messages
        @messages = response['messages']
        #test exit code for success/failure
        if response['exit_code'] == 0
          Rails.logger.debug("success! response")
          #success! > set attributes
          data = JSON.parse response['data']
          @app_info = data['app_info']
          data['user_info'].each do |key, value|
            if ['uuid', 'namespace', 'rhc_domain', 'ssh_key', 'key_type'].include? key
              send("#{key}=", value)
            elsif 'ssh_type' == key
              send("key_type=", value)
            end
          end #end userinfo block
        else
          errors.add(:base, response['result'])
        end #end if
      end #end response block
    rescue Exception => e
      errors.add(:base, I18n.t(:unknown)) if errors[:base].empty?
    end 
  end #end function

  def readable_ssh_key
    if not @ssh_key or @ssh_key.empty?
      "ssh-rsa nossh"
    else
      "#{@key_type} #{@ssh_key}"
    end
  end

end
