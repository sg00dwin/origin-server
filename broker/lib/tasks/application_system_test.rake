Rake::TestTask.new(:application_system_test) do |t|
  t.libs << "test"
  t.test_files = FileList['test/system/app_events_test.rb', 'test/system/application_test.rb']
  t.verbose = true
end