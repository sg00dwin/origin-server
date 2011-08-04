require 'openshift'

class ExpressDomain
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Serialization
  extend ActiveModel::Naming
  
  include ExpressApi
  
  attr_accessor :namespace, :ssh, :alter
    
  validates_presence_of :rhlogin
  validates :password, :length => {:minimum => 6},
                       :allow_blank => true
                     
  
  validates :namespace, :presence => true,
                        :length => {:maximum => 16},
                        :format => {:with => /^[A-Za-z0-9]+$/}
                        
  validate :namespace_not_in_blacklist
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
    process_pub_key unless @ssh.nil?
  end
  
  # Strip unnecessary data from ssh key
  def process_pub_key
    key_arr = @ssh.strip.split(' ')
    if key_arr.length > 1
      @ssh = key_arr[1]
    else
      @ssh.strip!
    end
  end
  
  def create
    @alter = "false"
    save do |response|
      yield response if block_given?
    end
  end
  
  def update
    @alter = "true"
    save do |response|
      yield response if block_given?
    end
  end
  
  private
  def save
    data = {:rhlogin => @rhlogin, :alter => @alter}
    data[:namespace] = @namespace
    data[:ssh] = @ssh.nil? ? '' : @ssh
    http_post(@@domain_url, data, true) do |json_response|
      Rails.logger.debug "response: #{json_response.inspect}"
      yield json_response if block_given?
    end
  end
  
  def namespace_not_in_blacklist
    unless @namespace.nil?
      errors.add(:namespace, "#{@namespace} is not permitted") if Libra::Blacklist.in_blacklist? @namespace
    end
  end
  
end
