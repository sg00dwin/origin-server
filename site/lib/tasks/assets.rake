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

  task :precompile_digested => 'assets:precompile' do
    asset_path = File.expand_path("#{Rails.root}/public/assets")
    manifest = YAML.load(File.read("#{asset_path}/manifest.yml"))
    manifest.each_pair do |file, dest|
      next unless ['.css', '.css.gz'].any?{ |s| file.end_with? s }
      puts "Update #{file} to use digested version"
      FileUtils.cp File.join(asset_path, dest), File.join(asset_path, file)
      if File.exists?(File.join(asset_path, "#{file}.gz"))
        FileUtils.cp File.join(asset_path, "#{dest}.gz"), File.join(asset_path, "#{file}.gz")
      end
    end
  end
end
