class ExpressDomain
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Serialization
  extend ActiveModel::Naming
  
  include ExpressApi
  
  attr_accessor :namespace, :ssh, :alter
  
  validates_presence_of :rhlogin
  validates :password, :length => {:minimum => 6} 
  
  validates :namespace, :presence => true,
                        :length => {:maximum => 16},
                        :format => {:with => /^[A-Za-z0-9]+$/}
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
    process_pub_key unless @ssh.nil?
  end
  
  # Read public key from uploaded file
  def process_pub_key
    unless @ssh.tempfile.nil?
      # read file
      begin
        key = @ssh.tempfile.read
      ensure
        @ssh.tempfile.close
      end
      unless key.nil?
        # strip ssh-rsa and comment
        key = key.strip.split(' ')[1]
        Rails.logger.debug "key: #{key}"
        # set key to string
        @ssh = key
      else
        errors[:ssh] = 'Unable to process ssh key'
      end
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
    Rails.logger.info 'Saving domain'
    data = {:rhlogin => @rhlogin, :alter => @alter}
    data[:namespace] = @namespace unless @namespace.nil?
    data[:ssh] = @ssh.strip unless @ssh.nil?
    http_post(@@domain_url, data, true) do |json_response|
      Rails.logger.info "response: #{json_response.inspect}"
      yield json_response if block_given?
    end
  end
  
end
