class GenerateSiteViewTask < GenerateConsoleViewTask
  protected
    def add_view_helpers(view, routes)
      view.class_eval do
        include routes.url_helpers
        include ApplicationHelper
        include CommunityHelper

        def user_signed_in?
          false
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
end
