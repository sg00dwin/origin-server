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

  Rake::TestTask.new :sanity => ['test:prepare'] do |t|
    t.libs << 'test'
    t.test_files = FileList[
      'test/unit/**/*_test.rb',
      'test/integration/login_flows_test.rb',
      'test/integration/streamline_test.rb',
#      'test/integration/aria_test.rb',
      'test/functional/applications_controller_sanity_test.rb',
      'test/functional/application_controller_test.rb',
      'test/functional/application_types_controller_test.rb',
#      'test/functional/console_controller_test.rb',
      'test/functional/email_confirm_controller_test.rb',
      'test/functional/login_controller_test.rb',
      'test/functional/logout_controller_test.rb',
      'test/functional/password_controller_test.rb',
      'test/functional/product_controller_test.rb',
      'test/functional/promo_code_mailer_test.rb',
      'test/functional/terms_controller_test.rb',
      'test/functional/user_controller_test.rb',
    ]
  end

  task :check => 'test'
  task :extended => 'test'
end
