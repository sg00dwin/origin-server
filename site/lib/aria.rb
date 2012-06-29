module Aria
  require_dependency 'aria/errors'
  require_dependency 'aria/client'

  def self.method_missing(method, *args, &block)
    if client.respond_to?(method)
      client.send(method, *args, &block)
    else
      raise NoMethodError
    end
  end
  def self.respond_to?(method)
    client.respond_to?(method) or super
  end

  private
    def self.client
      @client ||= Aria::Client.new
    end
end
