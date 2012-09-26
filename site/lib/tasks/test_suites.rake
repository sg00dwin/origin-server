namespace :test do

  console_path = File.expand_path(Gem.loaded_specs["openshift-origin-console"].full_gem_path)

  Rake::TestTask.new :streamline => 'test:prepare' do |t|
    t.libs << 'test'
    t.test_files = FileList[
      'test/**/*streamline*_test.rb',
      'test/**/web_user_test.rb',
      'test/**/login_flows_test.rb',
    ]
  end

  Rake::Task[:restapi].abandon
  Rake::TestTask.new :restapi => 'test:prepare' do |t|
    t.libs << 'test'
    t.test_files = FileList[
      "#{console_path}/test/**/rest_api_test.rb",
      "#{console_path}/test/**/rest_api/*_test.rb",
    ]
  end

  Rake::TestTask.new :aria => 'test:prepare' do |t|
    t.libs << 'test'
    t.test_files = FileList[
      'test/**/*aria*_test.rb',
      'test/**/plan_signup_flow_test.rb',
      'test/**/payment_methods_controller_test.rb',
      'test/**/billing_info_controller_test.rb',
      'test/**/account_upgrade*_test.rb',
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
      'test/functional/terms_controller_test.rb'
    ]
  end

  #
  # Test groups intended to be run in parallel for the build.
  #
  namespace :check do
    covered = []

    [:applications,
     :cartridges,
     :misc1,
     :restapi_integration,
     :base,
    ].each{ |s| Rake::Task[s].abandon }
    Rake::Task[:check].abandon

    Rake::TestTask.new :applications => ['test:prepare'] do |t|
      t.libs << 'test'
      covered.concat(t.test_files = FileList[
        'test/functional/applications_controller_sanity_test.rb',
        'test/functional/applications_controller_test.rb',
      ])
    end

    Rake::TestTask.new :cartridges => ['test:prepare'] do |t|
      t.libs << 'test'
      covered.concat(t.test_files = FileList[
        'test/functional/cartridges_controller_test.rb',
        'test/functional/cartridge_types_controller_test.rb',
      ])
    end

    Rake::TestTask.new :misc1 => ['test:prepare'] do |t|
      t.libs << 'test'
      covered.concat(t.test_files = FileList[
        'test/functional/domains_controller_test.rb',
        'test/functional/scaling_controller_test.rb',
        'test/functional/application_types_controller_test.rb',
      ])
    end

    Rake::TestTask.new :restapi_integration => ['test:prepare'] do |t|
      t.libs << 'test'
      covered.concat(t.test_files = FileList[
        'test/integration/rest_api/**_test.rb',
      ])
    end

    Rake::TestTask.new :base => ['test:prepare'] do |t|
      t.libs << 'test'
      t.test_files = FileList['test/**/*_test.rb'] - covered
    end
  end

  task :check => Rake::Task.tasks.select{ |t| t.name.match(/\Atest:check:/) }.map(&:name)
  task :extended => []
end
