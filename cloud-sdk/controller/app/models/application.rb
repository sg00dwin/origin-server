require 'rubygems'
require 'json'
require 'cloud-sdk-common'

class Application < Cloud::Sdk::Common::Model::Model
  attr_accessor :framework, :creation_time, :uuid, :embedded, :aliases, :name, :server_identity
  
  def initialize
    
  end
  
  def update_namespace(new_ns, old_ns)
    begin
      node = NodeProxy.new(@server_identity)
      result = node.execute_direct(app.framework, 'update_namespace', "#{app.name} #{self.namespace} #{self.namespace_was} #{app.uuid}")[0]
      if (result && defined?(result.results) && result.results.has_key?(:data))
        exitcode = result.results[:data][:exitcode]
        output = result.results[:data][:output]
        server.log_result_output(output, exitcode, self, app_name, app.attributes)
        return exitcode == 0
      end
    rescue Exception => e
      Rails.logger.debug "Exception caught updating namespace #{e.message}"
      Rails.logger.debug "DEBUG: Exception caught updating namespace #{e.message}"
      Rails.logger.debug e.backtrace
    end
    return false    
  end
end