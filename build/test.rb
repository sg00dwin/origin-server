namespace :test do
  desc "Run all tests"
  task :all do
    cd TESTS_ROOT
    sh "rake", "test:all"
  end
end
