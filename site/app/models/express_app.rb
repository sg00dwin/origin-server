require 'openshift'

class ExpressApp
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Serialization
  extend ActiveModel::Naming
  
  include ExpressApi
  
  attr_accessor :app_name, :cartridge, :debug
  attr_reader :health_path
  
  validates :app_name,  :presence => true,
                        :length => {:maximum => 16},
                        :format => {:with => /^[A-Za-z0-9]+$/}
  validates :cartridge, :presence => true
  
  validate :cartridge_list_is_present
  validate :cartridge_in_cartlist
  validate :app_name_not_in_blacklist

  def initialize(attributes = {})
    Rails.logger.debug "New Express App findmeexpressapp"
    attributes.each do |name, value|
      Rails.logger.debug "Setting #{name} to #{value}"
      send("#{name}=", value)
    end
    set_cartlist
  end
  
  def set_cartlist
    Rails.logger.debug "Setting cartlist"
    @cartlist = get_cartlist
    Rails.logger.debug "Cartlist: #{@cartlist.inspect}"
  end
  
  def get_cartlist
    Rails.logger.debug "Getting cartlist"
    (ExpressCartlist.new 'standalone').list
  end
  
  def configure
    data = get_data
    data[:action] = 'configure'
    json_data = ActiveSupport::JSON.encode(data)
    http_post @@app_url, json_data do |response|
      unless response['exit_code'] > 0
        data = ActiveSupport::JSON.decode response['data']
        @health_path = data['health_check_path']
      else
        errors.add :base, response['result']
      end
    end
  end
  
  private
  def get_data
    { :cartridge => @cartridge, 
      :app_name => @app_name, 
      :rhlogin => @rhlogin, 
      :debug => @debug ? 'true' : 'false' }
  end
  
  def cartridge_list_is_present
    errors.add(:base, "Unable to obtain cartridge list") unless @cartlist
  end
  
  def cartridge_in_cartlist
    if @cartlist and @cartridge
      errors.add(:cartridge, "#{@cartridge} is not a valid cartridge.") unless @cartlist.include? @cartridge
    end
  end
  
  def app_name_not_in_blacklist
    unless @app_name.nil?
      errors.add(:app_name, "#{@app_name} is not a permitted app name") if Libra::Blacklist.in_blacklist? @app_name 
    end
  end

end
