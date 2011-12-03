require 'rubygems'
require 'json'
require 'cloud-sdk-common'

class CloudUser < Cloud::Sdk::Model
  attr_accessor :rhlogin, :uuid, :ssh, :namespace, :system_ssh_keys, :env_vars, :email_address
  primary_key :rhlogin
  private :rhlogin=, :uuid=
  
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
  
  def initialize(rhlogin=nil, ssh=nil, namespace=nil)
    super()
    self.rhlogin, self.ssh, self.namespace = rhlogin, ssh, namespace
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
    end
    
    super()
  end

  def find_all
  end
  
  def applications
    Application.find_all(self)
  end
  
  private
  
  def create(response)
    notify_observers(:before_cloud_user_create)
    dns_service = DnsService.new
    begin
      if CloudUser.find(@rhlogin,@rhlogin)
        record.errors.add(attribute, {:message => "A user with RHLogin '#{@rhlogin}' already exists", :code => 102})
        raise "A user with RHLogin '#{@rhlogin}' already exists"
      end

      raise Cloud::Sdk::WorkflowException.new("A namespace with name '#{namespace}' already exists", 103) unless dns_service.namespace_available?(@namespace)

      Rails.logger.debug "DEBUG: Attempting to add namespace '#{@namespace}' for user '#{@rhlogin}'"      
      response.debug("Creating user entry login:#{@rhlogin} ssh:#{@ssh} namespace:#{@namespace}")
      dns_service.register_namespace(@namespace)
      @uuid = Cloud::Sdk::Model.gen_uuid
      dns_service.publish
      notify_observers(:cloud_user_create_success)      
    rescue Exception => e
      begin
        Rails.logger.debug "DEBUG: Attempting to remove namespace '#{@namespace}' after failure to add user '#{@rhlogin}'"        
        dns_service.deregister_namespace(@namespace)
        dns_service.publish
        notify_observers(:cloud_user_create_error)      
      ensure
        raise
      end
    ensure
      dns_service.close      
      notify_observers(:after_cloud_user_create)
    end
  end
  
  def update_namespace(response)
    notify_observers(:before_namespace_update)
    
    dns_service = DnsService.new
    raise Cloud::Sdk::WorkflowException.new("A namespace with name '#{namespace}' already exists", 103) unless dns_service.namespace_available?(@namespace)
    
    begin
      dns_service.register_namespace(self.namespace)
      dns_service.deregister_namespace(self.namespace_was)      

      applications.each do |app|
        Rails.logger.debug "DEBUG: Updating namespaces for app: #{app.name}"
        dns_service.deregister_application(app.name, self.namespace_was, @login)
        dns_service.register_application(app.name, self.namespace, @login)
      end
      
      update_namespace_failures = []
      applications.each do |app|
        Rails.logger.debug "DEBUG: Updating namespace for app: #{app_name}"
        result = app.update_namespace(self.namespace, self.namespace_was)
        update_namespace_failures.push(app.name) unless result
      end
      
      if update_namespace_failures.empty?
        dns_service.publish        
        notify_observers(:namespace_update_success)
      else
        notify_observers(:namespace_update_error)
        raise Cloud::Sdk::NodeException.new("Error updating apps: #{update_namespace_failures.pretty_inspect.chomp}.  Updates will not be completed until all apps can be updated successfully.  If the problem persists please contact support.",143), caller[0..5]
      end
    rescue Cloud::Sdk::CdkException => e
      raise
    rescue Exception => e
      response.debug "Exception caught updating namespace: #{e.message}"
      Rails.logger.debug "DEBUG: Exception caught updating namespace: #{e.message}"
      Rails.logger.debug e.backtrace
      raise Cloud::Sdk::CdkException.new("An error occurred updating the namespace.  If the problem persists please contact support.",1), caller[0..5]
    ensure
      dns_service.close
      
      applications.each do |app|
        app.embedded.each_key do |framework|
          if embedded["framework"].has_key?('info')
            info = embedded[framework]['info']
            info.gsub!(/-#{old_namespace}.#{Libra.c[:libra_domain]}/, "-#{new_namespace}.#{Libra.c[:libra_domain]}")
            embedded[framework]['info'] = info
          end
        end
        app.save        
      end
    end
    notify_observers(:after_namespace_update)
  end
end