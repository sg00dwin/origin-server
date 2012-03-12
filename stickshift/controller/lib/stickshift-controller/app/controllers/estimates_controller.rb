class EstimatesController < BaseController
  respond_to :xml, :json
  before_filter :authenticate

  # GET /estimates
  def index
    @reply = RestReply.new(:ok, "estimates", RestEstimates.new)
    respond_with @reply, :status => @reply.status
  end

  # GET /estimates/<id>  
  def show
    obj = params[:id]
    descriptor = params[:descriptor]
    if obj != "application"
      @reply = RestReply.new(:unprocessable_entity)
      message = Message.new(:error, "Invalid estimate object #{obj}.  Valid object: 'application'", 126, "estimates")
      @reply.messages.push(message)
    else
      begin
        # Get available framework cartriges
        standalone_carts = Application.get_available_cartridges("standalone")

        # Parse given application descriptor
        # FIXME: Work-around to convert single quoted string to double quoted string
        desc_lines = descriptor.split('\n')
        descriptor = desc_lines.join("\n")
        descriptor_hash = YAML.load(descriptor)
     
        # Find app framework
        framework = nil
        descriptor_hash['Requires'].each do |cart| 
          if standalone_carts.include?(cart)
            framework = cart
            break
          end
        end
        app_name = descriptor_hash['Name']
        raise Exception.new("Application name or framework not found in the descriptor.") if !framework or !app_name

        # Elaborate app descriptor
        template = ApplicationTemplate.new
        template.descriptor_yaml = descriptor
        app = Application.new(nil, app_name, nil, nil, framework, template)
        app.elaborate_descriptor

        # Generate output  
        groups = []
        app.group_instance_map.values.uniq.each do |ginst|
          components = []
          ginst.component_instances.each do |cname|
            cinst = app.comp_instance_map[cname]
            next if cinst.parent_cart_name == app.name
            comp = {}
            comp['Name'] = cinst.parent_cart_name
            components.push comp
          end if ginst
          app_gear = RestApplicationEstimate.new(components)
          groups.push(app_gear)
        end if app.group_instance_map
        @reply = RestReply.new(:ok, "application_estimates", groups)
      rescue Exception => e
        @reply = RestReply.new(:internal_server_error)
        message = Message.new(:error, "Invalid estimate object #{obj}.  Valid object: 'application'", 126, "estimates")
        @reply.messages.push(message)
      end
    end
    respond_with @reply, :status => @reply.status
  end
end
