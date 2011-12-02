require 'rubygems'
require 'json'
require 'cloud-sdk-common'

class LegacyReply < Cloud::Sdk::Model
  attr_accessor :api, :api_c, :broker, :broker_c, :debug, :messages, :result, :data, :exit_code  
  attr_accessor :debugIO, :resultIO, :messageIO, :errorIO, :appInfoIO

  
  API_VERSION    = "1.1.1"
  API_CAPABILITY = %w(placeholder)
  
  def initialize
    @api = API_VERSION
    @api_c = API_CAPABILITY
    #@broker = Cloud::Sdk::Controller::VERSION
    #@broker_c = Cloud::Sdk::Controller::CAPABILITY
    @debug = ""
    @messages = ""
    
    @debugIO = StringIO.new
    @resultIO = StringIO.new
    @messageIO = StringIO.new
    @errorIO = StringIO.new
    @appInfoIO = StringIO.new
  end
  
  def debug(str)
    @debug += str
  end
  
  def message(str)
    @messages += str
  end
  
  def data(str)
    @data += str
  end
end