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
      rx1 = Regexp.new(/^PROXY_HOST=(.*)/)
      rx2 = Regexp.new(/^PROXY_PORT=(.*)/)
      rx3 = Regexp.new(/^PORT=(.*)/)
      gears.each do |gear|
        comp_list = []
        gear.configured_components.each do |cname|
          comp_inst = app.comp_instance_map[cname]
          has_proxy_cart = true if cname.include? app.proxy_cartridge
          next if comp_inst.parent_cart_name == app.name

          begin
            res = gear.show_port(comp_inst).data

            m = rx1.match(res)
            proxy_host = m[1] if m 
            m = rx2.match(res)
            proxy_port = m[1].to_i if m 
            m = rx3.match(res)
            internal_port = m[1].to_i if m 
          rescue
            #ignore
          end

          comp_info = { 
                       'name' => comp_inst.parent_cart_name, 
                       'proxy_host' => proxy_host,
                       'proxy_port' => proxy_port,
                       'internal_port' => internal_port
                      }
          comp_list.push comp_info
        end

        app_name = app.name
        app_name = gear.uuid[0..9] if app.scalable and not has_proxy_cart
        git_url = "ssh://#{gear.uuid}@#{app_name}-#{cloud_user.namespace}." + Rails.application.config.cdk[:domain_suffix] + "/~/git/#{app_name}.git/"

        gear_info = RestGear.new(gear.uuid, comp_list, git_url)
        app_gears_info.push gear_info
      end

      @reply = RestReply.new(:ok, "gears", app_gears_info)
      respond_with @reply, :status => @reply.status
    end
  end
end
