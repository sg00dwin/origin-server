module Aria
  require_dependency 'aria/errors'
  require_dependency 'aria/client'
  require_dependency 'aria/user'
  require_dependency 'aria/methods'

  def self.method_missing(method, *args, &block)
    if Module.respond_to?(method)
      super
    else
      client.send(method, *args, &block)
    end
  end

  private
    def self.client
      @client ||= Aria::Client.new
    end
end
