require 'openshift'

class ExpressSshKey
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Serialization
  extend ActiveModel::Naming

  include ExpressApi

  attr_accessor :name, :public_key, :type, :primary, :rhlogin, :key_string, :mode
  attr_accessor :namespace # deprecated

  @@primary_key_name = 'default'

  validates_presence_of :public_key

  validates :name, :length => {:maximum => 50},
                   :presence => true,
                   :allow_blank => false

  validates_format_of :type,
                      :with => /^ssh-(rsa|dss)$/,
                      :message => "is not ssh-rsa or ssh-dss"

  def initialize(attributes = {})
    attributes.each do |name, value|
      if "key_string" == name
        parts = ExpressSshKey.parse_public_key_string(value)
        if parts
          @public_key = parts[:public_key]
          @type = parts[:type]
        else
          @public_key = value
        end
      elsif "primary" == name
        @primary = value
        if value == true
          @name = @@primary_key_name
        end
      else
        send("#{name}=", value)
      end
    end
  end

  def self.build(key_string, name, primary=false)
    parts = ExpressSshKey.parse_public_key_string(key_string)
    if parts
      ExpressSshKey.new({
        :name => name,
        :public_key => parts[:public_key],
        :type => parts[:type],
        :primary => primary
      })
    end
  end

  def self.find_secondary(rhlogin, ticket)
    keys = []

    begin

      data = {:rhlogin => rhlogin, :action => "list-keys"}
      ExpressApi.http_post(@@ssh_key_url, data, ticket) do |json_response|
        Rails.logger.debug json_response
        if json_response['exit_code'] > 0
          raise Exception json_response['data']
        end
  
        data = ActiveSupport::JSON.decode json_response['data']
        mykeys = data['keys']
  
        if mykeys
          mykeys.each do |name, details|
            unless details['key'] == "nossh" or details['key'] == ''
              key = ExpressSshKey.new({
                :name => name,
                :public_key => details['key'],
                :type => details['type'],
                :primary => false
              })
              keys << key
            end
          end
        end
      end
    rescue Exception => e
      Rails.logger.debug "Rescued Exception in ExpressSshKey#find_secondary: #{e.message}"
    end
    keys.sort! do |a,b|
      if a.primary?
        -1
      elsif b.primary?
        1
      else
        a.name <=> b.name
      end
    end
    keys
  end

  def self.primary_key_name
    return @@primary_key_name
  end

  def create
    if primary?
      persist_legacy
    else
      persist("add-key")
    end
  end

  def update
    if primary?
      persist_legacy
    else
      persist("update-key")
    end
  end

  def destroy
    persist("remove-key")
  end

  def primary?
    primary and primary != "" and primary != false and primary != "false" and primary != "0"
  end

  def placeholder?
    !public_key or public_key == '' or public_key == 'nossh'
  end

  def to_s
    if not placeholder? and type and public_key
      "#{type} #{public_key}"
    else
      ""
    end
  end

  def key_string
    to_s
  end

  def display_name(max_length=20)
    shorten(name, max_length)
  end

  def as_json(options={})
    {
      :name => name,
      :public_key => public_key,
      :primary => primary?,
      :type => type,
    }
  end

  private

  def persist(action)
    # allow removal of key objects with name only, otherwise validate
    if 'remove-key' == action || valid?
      data = {
        :rhlogin => @rhlogin,
        :action => action,
        :key_name => name
      }

      if "add-key" == action or "update-key" == action
        data[:ssh] = @public_key
        data[:key_type] = @type
      end

      http_post(@@ssh_key_url, data, false) do |json_response|
        Rails.logger.debug json_response
        if json_response['exit_code'] > 0
          Rails.logger.debug "error"
          errors.add :base, json_response['result']
        end
      end
    end
  end

  def persist_legacy

    # ensure name is set
    @name = @@primary_key_name

    if valid?
      data = {:rhlogin => @rhlogin, :alter => true}

      data[:namespace] = @namespace
      data[:ssh] = @public_key
      data[:key_type] = @type

      http_post(@@domain_url, data, false) do |json_response|
        if json_response['exit_code'] > 0
          errors.add :base, json_response['result']
        end
      end
    end
  end

  def shorten(str, max_length=20)
    len = max_length - 3
    if str and str.length > len
      str.slice(0, len) + '...'
    else
      str
    end
  end

  def self.parse_public_key_string(str)
    if str =~ /^(ssh-rsa|ssh-dss)\s+([^\s]+)/
      {
        :public_key => $2,
        :type => $1
      }
    end
  end
end
