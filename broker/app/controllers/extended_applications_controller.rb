class ExtendedApplicationsController < ApplicationsController
  respond_to :xml, :json
  before_filter :authenticate
  alias :old_create :create

  def create
    if params[:template].nil?
      old_create
    else
      template = ApplicationTemplate.find(params[:template])
      if template.nil?
        @reply = RestReply.new( :bad_request)
        message = Message.new(:error, "Invalid template #{params[:template]}.") 
        @reply.messages.push(message)
        respond_with @reply, :status => @reply.status
      else
        descriptor = YAML.load(template.descriptor_yaml)
        
        params[:cartridge] = descriptor["Requires"].first
        application = validate_create_params
        
        descriptor["Name"] = application.name
        application.from_descriptor(descriptor)
        
        create_and_configure_application(application)
      end
    end
  end

end