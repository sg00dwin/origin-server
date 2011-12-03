require 'rubygems'
require 'json'
require 'cloud-sdk-common'

class LegacyReply < Cloud::Sdk::Model
  attr_accessor :api, :api_c, :broker, :broker_c, :debug, :message, :result, :data, :exit_code  
  attr_accessor :debugIO, :resultIO, :messageIO, :errorIO, :appInfoIO

  
  API_VERSION    = "1.1.1"
  API_CAPABILITY = %w(placeholder)
  C_VERSION      = "1.1.1"
  C_CAPABILITY   = %w(namespace rhlogin ssh app_uuid debug alter cartridge cart_type action app_name api)
  
  def initialize
    @api = API_VERSION
    @api_c = API_CAPABILITY
    @broker = C_VERSION
    @broker_c = C_CAPABILITY
    @debug = ""
    @message = nil
  end
end