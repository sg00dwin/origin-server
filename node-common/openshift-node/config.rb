
require 'rubygems'
require 'parseconfig'

module Node

  class Config
    attr_accessor :resource_limits
    def initialize(uuid)
      @uuid = uuid
      config = File.expand_path("~#{uuid}/.resource_limits")
      @resource_limits = ParseConfig.new(config)
    end
  end
end
