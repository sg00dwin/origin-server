namespace :test do

  Rake::TestTask.new :sanity => ['test:prepare'] do |t|
    t.libs << 'test'
    t.test_files = FileList[
      'test/unit/**/*_test.rb',
      'test/functional/**/*_test.rb',
      'test/integration/**/*_test.rb'
    ]
  end

  Rake::TestTask.new :domain_system_test => ['test:prepare'] do |t|
    t.libs << 'test'
    t.test_files = FileList['test/system/domain_test.rb']
    t.verbose = true
  end

  Rake::TestTask.new :cartridge_system_test => ['test:prepare'] do |t|
    t.libs << "test"
    t.test_files = FileList['test/system/app_cartridge_events_test.rb', 'test/system/app_cartridges_test.rb']
    t.verbose = true
  end

  Rake::TestTask.new :application_system_test => ['test:prepare'] do |t|
    t.libs << "test"
    t.test_files = FileList['test/system/app_events_test.rb', 'test/system/application_test.rb']
    t.verbose = true
  end

  Rake::TestTask.new :usage => ['test:prepare'] do |t|
    t.libs << 'test'
    t.test_files = FileList[
      'test/usage/unit/**/*_test.rb',
      'test/usage/functional/**/*_test.rb',
      'test/usage/integration/**/*_test.rb'
    ]
  end
  
  Rake::TestTask.new :ctl_usage => ['test:prepare'] do |t|
    t.libs << 'test'
    t.test_files = FileList['test/usage/integration/ctl_usage_test.rb']
  end

end
