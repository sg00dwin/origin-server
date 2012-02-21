class ApplicationTemplateController < BaseController
  respond_to :xml, :json
    
  def index
    templates = ApplicationTemplate.find_all
    @reply = RestReply.new(:ok, "application_templates", templates)
    respond_with @reply, :status => @reply.status
  end
  
  def show
    id_or_tag = params[:id]
    template = ApplicationTemplate.find(id_or_tag)
    unless template.nil?
      @reply = RestReply.new(:ok, "application_template", template)
      respond_with @reply, :status => @reply.status
    else
      templates = ApplicationTemplate.find_by_tag(id_or_tag)      
      @reply = RestReply.new(:ok, "application_templates", templates)
      respond_with @reply, :status => @reply.status
    end
  end
end