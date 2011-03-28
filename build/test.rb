begin
  namespace :test do
    require "cucumber/rake/task"

    desc "Run all tests"
    Cucumber::Rake::Task.new(:all) do |t|
      t.cucumber_opts = "tests"
      t.fork = false
    end
  end
rescue LoadError
    # Ignore error - this allows rake to be run from
    # non-development servers
end
