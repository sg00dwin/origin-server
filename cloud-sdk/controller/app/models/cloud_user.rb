require 'rubygems'
require 'json'
require 'cloud-sdk-common'

class CloudUser < Cloud::Sdk::Model
  attr_accessor :login, :uuid, :ssh, :namespace, :system_ssh_keys, :env_vars, :email_address
  private :login=, :uuid=
  
  validates_each :login do |record, attribute, val|
    record.errors.add(attribute, {:message => "Invalid characters found in RHlogin '#{val}' ", :code => 107}) if val =~ /["\$\^<>\|%\/;:,\\\*=~]/
  end
  
  validates_each :namespace do |record, attribute, val|
    if !(val =~ /\A[A-Za-z0-9]+\z/)
      record.errors.add attribute, {:message => "Invalid namespace: #{val}", :exit_code => 106}
    end
  end
  
  validates_each :ssh do |record, attribute, val|
    if !(val =~ /\A[A-Za-z0-9\+\/=]+\z/)
      record.errors.add attribute, {:message => "Invalid ssh key: #{val}", :exit_code => 108}
    end
  end
  
  def initialize(login, ssh, namespace)
    self.login, self.ssh, self.namespace = login, ssh, namespace
  end
  
  def save(response)
    unless persisted?
      #new user record
      create(response)
    else
      if ssh_changed?
        apps.each do |appname, app|
          server = Libra::Server.new app.server_identity
          server.remove_ssh_key(app.attributes, self.ssh_was)
          server.add_ssh_key(app.attributes, self.ssh)
        end
      end
      update_namespace(response) if namespace_changed?
      super()
    end
  end

  def find_all
  end
  
  def find_by_login(login)
  end
  
  def applications
    Application.find_by_user(uuid)
  end
  
  def attributes=(hash)
    hash.each do |key,value|
      instance_variable_set("@#{key}",value)
    end
  end
  
  private
  
  def create(response)
    notify_observers(:before_cloud_user_create)
    dns_service = DnsService.new
    begin
      if find_by_login(@login)
        record.errors.add(attribute, {:message => "A user with RHLogin '#{@login}' already exists", :code => 102})
        raise "A user with RHLogin '#{@login}' already exists"
      end

      raise Cloud::Sdk::WorkflowException.new("A namespace with name '#{namespace}' already exists", 103) unless dns_service.namespace_available?(@namespace)

      logger.debug "DEBUG: Attempting to add namespace '#{@namespace}' for user '#{@login}'"      
      response.debug("Creating user entry login:#{@login} ssh:#{@ssh} namespace:#{@namespace}")
      dns_service.register_namespace(@namespace)
      dns_service.publish
      @uuid = Cloud::Sdk::Common::Model::Model.gen_uuid
      super.save()
      begin
        notify_observers(:cloud_user_create_success)
      rescue Exception => e
        logger.debug "DEBUG: Attempting to delete user '#{@login}' due to failure in cloud_user_create_success callback"
        begin
          super.delete()
        ensure
          raise
        end
      end
    rescue Exception => e
      notify_observers(:cloud_user_create_error)
      begin
        logger.debug "DEBUG: Attempting to remove namespace '#{@namespace}' after failure to add user '#{@login}'"        
        dns_service.deregister_namespace(@namespace)
        dns_service.publish
      ensure
        raise
      end
    ensure
      notify_observers(:after_cloud_user_create)
      dns_service.close
    end
    response
  end
  
  def update_namespace(response)
    notify_observers(:before_namespace_update)
    old_namespace = self.namespace_was
    dns_service = DnsService.new
    raise Cloud::Sdk::WorkflowException.new("A namespace with name '#{namespace}' already exists", 103) unless dns_service.namespace_available?(@namespace)
    
    begin
      dns_service.register_namespace(@namespace)
      dns_service.deregister_namespace(old_namespace)      

      apps.each do |app_name, app|
        logger.debug "DEBUG: Updating namespaces for app: #{app_name}"
        server = Server.new(app.server_identity)
        server.recreate_app_dns_entries(app_name, old_namespace, @namespace, auth_token, dyn_retries)
      end
      
      update_namespace_failures = []
      apps.each do |app_name, app|
        begin
          logger.debug "DEBUG: Updating namespace for app: #{app_name}"
          server = Server.new(app.server_identity)
          result = server.execute_direct(app.framework, 'update_namespace', "#{app_name} #{@namespace} #{old_namespace} #{app.uuid}")[0]
          if (result && defined? result.results && result.results.has_key?(:data))            
            exitcode = result.results[:data][:exitcode]
            output = result.results[:data][:output]
            server.log_result_output(output, exitcode, self, app_name, app.attributes)
            if exitcode != 0
              update_namespace_failures.push(app_name)                
            end
          else
            update_namespace_failures.push(app_name)
          end
        rescue Exception => e
          logger.debug "Exception caught updating namespace #{e.message}"
          logger.debug "DEBUG: Exception caught updating namespace #{e.message}"
          logger.debug e.backtrace
          update_namespace_failures.push(app_name)
        end
      end
      
      if update_namespace_failures.empty?
        notify_observers(:namespace_update_success)
      else
        notify_observers(:namespace_update_error)
        raise Cloud::Sdk::NodeException.new("Error updating apps: #{update_namespace_failures.pretty_inspect.chomp}.  Updates will not be completed until all apps can be updated successfully.  If the problem persists please contact support.",143), caller[0..5]
      end
      
      dns_service.publish
    rescue Cloud::Sdk::CdkException => e
      raise
    rescue Exception => e
      response.debug "Exception caught updating namespace: #{e.message}"
      logger.debug "DEBUG: Exception caught updating namespace: #{e.message}"
      logger.debug e.backtrace
      raise Cloud::Sdk::CdkException.new("An error occurred updating the namespace.  If the problem persists please contact support.",1), caller[0..5]
    ensure
      dns_service.close
      super.save()
      
      apps.each do |app_name, app|
        app.embedded.each_key do |framework|
          if embedded["framework"].has_key?('info')
            info = embedded[framework]['info']
            info.gsub!(/-#{old_namespace}.#{Libra.c[:libra_domain]}/, "-#{new_namespace}.#{Libra.c[:libra_domain]}")
            embedded[framework]['info'] = info
          end
          app.save
        end
      end
    end
    notify_observers(:after_namespace_update)
  end
end