class ApplicationObserver < ActiveModel::Observer
  observe Application

  BUILDER_SUFFIX = "bldr"
  
  def track_usage(data)
    gear_uuid = data[:gear_uuid]
    login = data[:login]
    event = data[:event]
    time = data[:time]
    uuid = data[:uuid]
    usage_type = data[:usage_type]
    gear_size = data[:gear_size]
    addtl_fs_gb = data[:addtl_fs_gb]
    usage = nil
    if event == UsageRecord::EVENTS[:begin]
      usage = Usage.new(login, gear_uuid, time, nil, uuid, usage_type)
      usage.gear_size = gear_size if gear_size
      usage.addtl_fs_gb = addtl_fs_gb if addtl_fs_gb 
    elsif event == UsageRecord::EVENTS[:end]
      usage = Usage.find_latest_by_gear(gear_uuid)
      if usage
        usage.end_time = time
        usage.usage_type = usage_type  #TODO can remove this after the 2.0.15 release
      end
    end
    usage.save! if usage
  end

  def before_application_create(data)
    application = data[:application]
    reply = data[:reply]

    unless application.node_profile
      capabilities = application.user.get_capabilities
      user_gear_sizes = []
      user_gear_sizes = capabilities['gear_sizes'] if capabilities.has_key?('gear_sizes')
      if user_gear_sizes.length == 1
        application.node_profile = user_gear_sizes[0]
      elsif user_gear_sizes.length > 1
        if user_gear_sizes.include?(Rails.application.config.ss[:default_gear_size])
          application.node_profile = Rails.application.config.ss[:default_gear_size]
        else
          application.node_profile = user_gear_sizes[0]
        end
      else
        application.node_profile = Rails.application.config.ss[:default_gear_size]
      end
    end

    if application.name =~ /.+#{BUILDER_SUFFIX}$/
      reply.messageIO << "
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
WARNING: The '#{BUILDER_SUFFIX}' suffix is used by the CI system (Jenkins) for its slave 
builders.  If you create an app of this name you can't also create an app 
called '#{application.name[0..-(BUILDER_SUFFIX.length+1)]}' and build that app in Jenkins without conflicts.
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
"
    end

    if application.framework_cartridge == 'jenkins'
      application.user.applications.each do |uapp|
        if uapp.framework_cartridge == "jenkins"
          raise StickShift::UserException.new("A jenkins application named '#{uapp.name}' in namespace '#{application.domain.namespace}' already exists.  You can only have 1 jenkins application per account.", 115)
        end

        if application.name == "#{uapp.name}#{BUILDER_SUFFIX}"
          reply.messageIO << "
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
WARNING: You already have an app created named '#{uapp.name}#{BUILDER_SUFFIX}'.  Be aware that
if you build '#{uapp.name}' using Jenkins it will destroy '#{uapp.name}#{BUILDER_SUFFIX}'.  This
may be ok if '#{uapp.name}#{BUILDER_SUFFIX}' was the builder of a previously destroyed app.
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
"
        end
      end
    end

    unless Application.find(application.user, application.name).nil?
      raise StickShift::UserException.new("An application named '#{application.name}' in namespace '#{application.domain.namespace}' already exists", 100)
    end

    if application.framework_cartridge == 'jenkins'
      application.user.applications.each do |app|
        if app.framework_cartridge == 'jenkins'
          raise StickShift::UserException.new("A jenkins application named '#{application.name}' in namespace '#{application.domain.namespace}' already exists. You can only have 1 jenkins application per account.", 115)
        end
      end
    end
    
    if application.user.auth_method == :login and not StickShift::ApplicationContainerProxy.valid_gear_sizes(application.user).include?(application.node_profile)
      raise StickShift::UserException.new("Invalid Profile: #{application.node_profile}.  Must be: #{StickShift::ApplicationContainerProxy.valid_gear_sizes(application.user).join(", ")}", 1)
    end
  end
  
  def after_application_destroy(data)
    app = data[:application]
    reply = data[:reply]
    if app.framework_cartridge == "jenkins"
      app.user.applications.each do |uapp|
        begin
          reply.append uapp.remove_dependency('jenkins-client-1.4') if uapp.name != app.name and uapp.embedded and uapp.embedded.has_key?('jenkins-client-1.4')
        rescue Exception => e
          reply.debugIO << "Failed to remove jenkins client from application: #{uapp.name}\n"
        end
      end
    end
  end
end
