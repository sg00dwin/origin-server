class ApplicationObserver < Mongoid::Observer
  observe :application

  def after_destroy(app)
    web_framework_carts = CartridgeCache.cartridge_names("web_framework")
    framework = app.component_instances.select{ |cinst| web_framework_carts.include?(cinst.cartridge_name)}.first
    framework = framework.cartridge_name if framework
    Online::Broker::Nurture.application(app.domain.owner.login, app.owner._id, app.name, app.domain_namespace, framework, "deconfigure", app.uuid, app.user_agent, app.init_git_url)
  end
end