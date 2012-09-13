def action_view
  controller = ConsoleController.new
  controller.request = ActionDispatch::TestRequest.new
  view = ActionView::Base.new(ActionController::Base.view_paths, {}, controller)

  routes = Rails.application.routes
  routes.default_url_options = {:host => 'localhost'}

  view.class_eval do
    include routes.url_helpers
    include Console::LayoutHelper
    include Console::HelpHelper
    include Console::Html5BoilerplateHelper
    include Console::ModelHelper
    include Console::SecuredHelper
    include Console::CommunityHelper
    include Console::ConsoleHelper

    def protect_against_forgery?
      false
    end

    def default_url_options
       {host: 'localhost'}
    end
  end
end

namespace :assets do
  task :public_pages => :environment do
    File.open(File.join(Rails.root, 'public', '404.html'), 'w') do |f|
      f.write(action_view.render :template => 'shared/not_found', :layout => 'layouts/console')
    end
  end
end
