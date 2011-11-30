require 'rubygems'
require 'json'
require 'cloud-sdk-common'

class Application < Cloud::Sdk::Common::Model::Model
  attr_accessor :framework, :creation_time, :uuid, :embedded, :aliases
  
  def initialize
    
  end
end