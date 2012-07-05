Rake::TestTask.new(:domain_system_test) do |t|
  t.libs << "test"
  t.test_files = FileList['test/system/domain_test.rb']
  t.verbose = true
end