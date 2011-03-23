begin
  namespace :test do
    require "cucumber/rake/task"

    desc "Run all unit tests"
    Cucumber::Rake::Task.new(:unit) do |t|
      t.cucumber_opts = "tests --tags @unit"
    end

    desc "Run all integration tests"
    Cucumber::Rake::Task.new(:integration) do |t|
      t.cucumber_opts = "tests --tags ~@sprint"
    end

    desc "Run the sprint tests"
    task :cuc_sprint do |t, args|
      Cucumber::Rake::Task.new(:sprint) do |t|
        t.cucumber_opts = "tests --tags @sprint"
      end
    end
  end
rescue LoadError
    # Ignore error - this allows rake to be run from
    # non-development servers
end
