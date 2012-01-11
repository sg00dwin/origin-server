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
                        
  validates :ssh, :presence => true,
                        :format => {:with => /^(ssh-rsa|ssh-dss)\s+.*$/}
                        
  validate :namespace_not_in_blacklist
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def parse_pub_key
    if @ssh =~ /^(ssh-rsa|ssh-dss)\s+(.*)/
      {
        :ssh_key => $2,
        :key_type => $1
      }
    end
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

    key_data = parse_pub_key
    data = {:rhlogin => @rhlogin, :alter => @alter}
    data[:namespace] = @namespace
    data[:ssh] = key_data[:ssh_key]
    data[:key_type] = key_data[:key_type]

    http_post(@@domain_url, data, true) do |json_response|
      yield json_response if block_given?
    end
  end
  
  def namespace_not_in_blacklist
    unless @namespace.nil?
      errors.add(:namespace, "#{@namespace} is not permitted") if OpenShift::Blacklist.in_blacklist? @namespace
    end
  end
  
end
