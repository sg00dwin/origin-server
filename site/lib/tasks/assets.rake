class GenerateSiteViewTask < GenerateConsoleViewTask
  protected
    def add_view_helpers(view, routes)
      view.class_eval do
        include routes.url_helpers
        include ApplicationHelper
        include Console::CommunityAware
        include CommunityHelper

        def user_signed_in?
          false
        end

        def active_tab
          nil
        end
      end
    end
end

namespace :assets do
  Rake::Task[:public_pages].abandon
  GenerateSiteViewTask.new(:public_pages) do |t|
    t.layout = 'layouts/site'
    t.views = {
      'product/not_found' => '404.html',
      'console/error'     => '500.html',
    }
  end
  GenerateSiteViewTask.new(:generic_error_pages) do |t|
    t.layout = nil
    t.views = {
      'product/core_not_found'       => 'error/404.html',
      'product/core_error'           => 'error/500.html',
      'product/core_unavailable'     => 'error/503.html',
      'product/core_request_denied'  => 'error/request_denied.html',
      'product/core_app_error'       => 'error/app/500.html',
      'product/core_app_unavailable' => 'error/app/503.html',
      'product/core_app_installing'  => 'error/app/installing.html',
    }
  end
end
