namespace :test do

  Rake::TestTask.new :sanity => ['test:prepare'] do |t|
    t.libs << 'test'
    t.test_files = FileList[
      'test/unit/**/*_test.rb',
      'test/functional/**/*_test.rb',
      'test/integration/**/*_test.rb'
    ]
  end
end
