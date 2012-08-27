raise "engine.rake was backported from 3.1, remove" unless Gem::Requirement.create("~> 3.0.0") =~ Gem.loaded_specs['rails'].version
unless defined? ENGINE_LOADED
  task "load_app" do
    namespace :app do
      load APP_RAKEFILE
    end
    task :environment => "app:environment"

    if !defined?(ENGINE_PATH) || !ENGINE_PATH
      ENGINE_PATH = find_engine_path(APP_RAKEFILE)
    end
  end

  def find_engine_path(path)
    return File.expand_path(Dir.pwd) if path == "/"

    if Rails::Engine.find(path)
      path
    else
      find_engine_path(File.expand_path('..', path))
    end
  end

  ENGINE_LOADED = true
  Rake.application.invoke_task(:load_app)
end
