class ApplicationObserver < ActiveModel::Observer
  observe Application

  BUILDER_SUFFIX = "bldr"
  
  def validate_application(app)
    #TODO
    #app.user.validate_app_limit
  end
  
  def before_application_create(data)
    application = data[:application]
    reply = data[:reply]
    
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
          raise Cloud::Sdk::CdkException.new("A jenkins application named '#{uapp.name}' in namespace '#{application.user.namespace}' already exists.  You can only have 1 jenkins application per account.", 115) 
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
      raise Exception.new("An applicaiton named '#{application.name}' in namespace '#{application.user.namespace}' already exists", 100)
    end

    if application.framework_cartridge == 'jenkins'
      application.user.applications.each do |app|
        if app.framework_cartridge == 'jenkins'
          raise Cloud::Sdk::CdkException.new("A jenkins application named '#{application.name}' in namespace '#{application.user.namespace}' already exists. You can only have 1 jenkins application per account.", 115)
        end
      end
    end
  end
end
