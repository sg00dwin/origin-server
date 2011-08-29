class ExpressCartlist
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Serialization
  extend ActiveModel::Naming
  
  include ExpressApi
  
  attr_accessor :list, :cart_type, :debug
  
  validates :cart_type, :presence => true,
                        :inclusion => { :in => ['standalone', 'embedded'] } 
                        
  @@cache_timeout = 14400
  
  def initialize( cart_type, debug = false )
    @cart_type = cart_type
    @debug = debug ? 'true' : 'false'
    set_list
  end
  
  def set_list
    if refresh_cache? or not File.exists? cache_file
      establish
    else
      begin
        get_cached_list
      rescue Exception => e
        Rails.logger.error "Unable to get cached cartlist - #{e.message}"
        establish #fallback to api
      end
    end
  end
  
  def refresh_cache?
    Time.now.to_i - cached_time >= @@cache_timeout
  end
  
  def establish
    data = { :cart_type => @cart_type, :debug => @debug }
    json_data = ActiveSupport::JSON.encode data
    Rails.logger.debug "data to post: #{json_data}"
    http_post @@cartlist_url, json_data do |response|
      Rails.logger.debug "Cartlist response is #{response.inspect}"
      unless response['exit_code'] > 0
        data = ActiveSupport::JSON.decode response['data']
        @list = data['carts']
        begin
          cache_list
        rescue Exception => e
          #fail gracefully
          Rails.logger.error "Unable to create cartlist cache - #{e.message}"
        end
      else
        errors.add(:base, response['result'])
      end
    end
  end
  
  def cache_list
    json_list = ActiveSupport::JSON.encode @list
    File.delete cache_file if File.exists? cache_file
    f = File.open cache_file, 'w'
    f.write json_list
  end
  
  def cache_file
    "tmp/#{@cart_type}"
  end
  
  def get_cached_list
    f = File.open cache_file
    cached_list = f.read
    Rails.logger.debug "Cached list: #{cached_list}"
    @list = ActiveSupport::JSON.decode cached_list
  end
  
  def cached_time
    begin
      (File.mtime cache_file).to_i
    rescue Errno::ENOENT
      Rails.logger.debug "Cache doesn't exist"
      Time.now.to_i - @@cache_timeout
    end
  end

end
