Rake::TestTask.new(:cartridge_system_test) do |t|
  t.libs << "test"
  t.test_files = FileList['test/system/app_cartridge_events_test.rb', 'test/system/app_cartridges_test.rb']
  t.verbose = true
end