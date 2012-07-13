namespace :test do
  Rake::TestTask.new :streamline => 'test:prepare' do |t|
    t.libs << 'test'
    t.test_files = FileList[
      'test/**/*streamline*_test.rb',
      'test/**/web_user_test.rb',
      'test/**/login_flows_test.rb',
    ]
  end

  Rake::TestTask.new :restapi => 'test:prepare' do |t|
    t.libs << 'test'
    t.test_files = FileList[
      'test/**/rest_api_test.rb',
      'test/**/rest_api/*_test.rb',
    ]
  end

  Rake::TestTask.new :aria => 'test:prepare' do |t|
    t.libs << 'test'
    t.test_files = FileList[
      'test/**/*aria*_test.rb',
      'test/**/plan_signup_flow_test.rb',
      'test/**/account_upgrades_controller_test.rb',
    ]
  end
end
