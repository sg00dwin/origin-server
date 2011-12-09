class ApplicationObserver < ActiveModel::Observer
  observe Application

  BUILDER_SUFFIX = "bldr"
  
  def validate_application(app)    
    if app.name =~ /.+#{BUILDER_SUFFIX}$/
      @reply.message "
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
WARNING: The '#{BUILDER_SUFFIX}' suffix is used by the CI system (Jenkins) for its slave 
builders.  If you create an app of this name you can't also create an app 
called '#{app.name[0..-(BUILDER_SUFFIX.length+1)]}' and build that app in Jenkins without conflicts.
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
"
    end
    
    if type == 'jenkins'
      app.user.applications.each do |uapp|
        raise Cloud::Sdk::CdkException.new("A jenkins application named '#{uapp.name}' in namespace '#{app.user.namespace}' already exists.  You can only have 1 jenkins application per account." 115) if uapp.framework_cartridge == "jenkins"
      end

      if app.name == "#{uapp.name}#{BUILDER_SUFFIX}"
        @reply.message "
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
WARNING: You already have an app created named '#{uapp.name}#{BUILDER_SUFFIX}'.  Be aware that
if you build '#{uapp.name}' using Jenkins it will destroy '#{uapp.name}#{BUILDER_SUFFIX}'.  This
may be ok if '#{uapp.name}#{BUILDER_SUFFIX}' was the builder of a previously destroyed app.
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
"
        break
      end
    end
    
    #TODO
    #app.user.validate_app_limit
  end
  
  def before_application_create(application)
    #raise Exception.new(100), "An applicaiton named '#{application.name}' in namespace '#{application.user.namespace}' already exists", caller[0..5] if applicatin.user.app_info(application.name)

    apps = application.user.applications
    type = application.framework_cartridge
    if type == 'jenkins'
      apps.each do |appname, app|
        if app.framework_cartridge == 'jenkins'
          raise Exception.new(115), "A jenkins application named '#{application.name}' in namespace '#{application.user.namespace}' already exists. You can only have 1 jenkins application per account.", caller[0..5]
        end
      end
    end
  end
end
