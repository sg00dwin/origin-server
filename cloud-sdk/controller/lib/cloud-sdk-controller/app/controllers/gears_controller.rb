class GearsController < BaseController
  respond_to :xml, :json
  before_filter :authenticate
  include LegacyBrokerHelper
  
  def show
    domain_id = params[:domain_id]
    app_id = params[:application_id]
    
    cloud_user = CloudUser.find(@login)
    app = Application.find(cloud_user,app_id)
    
    if app.nil?
      @reply = RestReply.new(:not_found)
      message = Message.new(:error, "Application #{id} not found.")
      @reply.messages.push(message)
      respond_with @reply, :status => @reply.status
    else
      app_gears_info = []
      gears = app.group_instances.uniq.map{ |ginst| ginst.gears }.flatten
      has_proxy_cart = false
      gears.each do |gear|
        gear.configured_components.each do |cname|
          if cname.include? app.proxy_cartridge
            has_proxy_cart = true 
            break 
          end
        end
      end
      gears.each do |gear|
        comp_list = []
        gear.configured_components.each do |cname|
          comp_inst = app.comp_instance_map(cname)
          comp_list.push { "name" : comp_inst.parent_cart_name, "proxy_port" : gear.show_port(comp_inst) }
        end
        app_name = app.name
        app_name = gear.uuid[0..9] if app.scalable and has_proxy_cart
        git_url = "ssh://#{gear.uuid}@#{app_name}-#{cloud_user.namespace}" + Rails.applicaton.config.cdk[:domain_suffix] + "/~/git/#{app_name}.git/"
        gear_info = RestGear.new(gear.uuid, comp_list, git_url)
        app_gears_info.push gear_info
      end
      @reply = RestReply.new(:ok, "gears", app_gears_info)
      respond_with @reply, :status => @reply.status
    end
  end
end
