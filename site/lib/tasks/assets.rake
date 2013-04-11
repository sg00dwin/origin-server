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

        def account_settings_redirect
          settings_account_path
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
      'product/core_not_found'   => 'core-404.html',
      'product/core_error'       => 'core-500.html',
      'product/core_unavailable' => 'core-503.html',
      'product/core_app_error'   => 'core-app-500.html',
    }
  end
end
