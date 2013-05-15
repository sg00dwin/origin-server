def migrate_gear(app, gear_uuid)
  output = `rhc-admin-migrate --app-name #{@app.name} --login #{@app.login} --migrate-gear #{gear_uuid} --version 2.0.28`
  $logger.info("Migration output: #{output}")
  assert_equal 0, $?.exitstatus
end

def get_gear_ids_for_scalable_app(app)
  url = "https://localhost/broker/rest/domains/#{app.namespace}/applications/#{app.name}/gear_groups.json"

  $logger.info("Broker url: #{url}")

  params = {
    'broker_auth_key' => File.read(File.join($home_root, app.uid, '.auth', 'token')).chomp,
    'broker_auth_iv' => File.read(File.join($home_root, app.uid, '.auth', 'iv')).chomp
  }
  
  request = RestClient::Request.new(:method => :get, 
                                    :url => url, 
                                    :timeout => 120,
                                    :headers => { :accept => 'application/json;version=1.0', :user_agent => 'OpenShift' },
                                    :payload => params)
  
  begin
    response = request.execute()

    if 300 <= response.code 
      $logger.warn(response)
      raise response
    end
  rescue 
    raise
  end

  begin
    gear_groups = JSON.parse(response)
  rescue
    raise
  end

  gear_ids = []

  gear_groups['data'].each do |data|
    data['gears'].each do |gear|
      gear_ids << gear['id']
    end
  end

  $logger.info("Gear IDs: #{gear_ids.inspect}")

  gear_ids
end

When /^the application is migrated to the v2 cartridge system$/ do
  if @app.scalable
    get_gear_ids_for_scalable_app(@app).each do |gear_uuid|
      migrate_gear(@app, gear_uuid)
    end
  else
    migrate_gear(@app, @app.uid)
  end
end

Then /^the environment variables will be migrated to raw values$/ do
  Dir.glob(File.join($home_root, @app.uid, '.env', '*')).each do |entry|
    next if File.directory?(entry)
    value = IO.read(entry)
    assert !value.start_with?('export'), entry
  end
end

Then /^the application will be marked as a v2 app$/ do
  marker_file = File.join($home_root, @app.uid, '.env', 'CARTRIDGE_VERSION_2')

  assert_file_exists marker_file
end

Given /^the application has a (USER_VARS|TRANSLATE_GEAR_VARS) env file$/ do |name|
  IO.write(File.join($home_root, @app.uid, '.env', name), '')
end

Then /^the (USER_VARS|TRANSLATE_GEAR_VARS) file will not exist$/ do |name|
  file = File.join($home_root, @app.uid, '.env', name)

  assert_file_not_exists file
end

Given /^the application has a TYPELESS_TRANSLATED_VARS env file$/ do
  typeless_vars = %Q{
export TEST_VAR_1='foo'
export TEST_VAR_2='bar'    
  }

  IO.write(File.join($home_root, @app.uid, '.env', 'TYPELESS_TRANSLATED_VARS'), typeless_vars)
end

Then /^the TYPELESS_TRANSLATED_VARS variables will be discrete variables$/ do
  test_var = File.join($home_root, @app.uid, '.env', 'TEST_VAR_1')

  content = IO.read(test_var)

  assert content == 'foo'

  test_var = File.join($home_root, @app.uid, '.env', 'TEST_VAR_2')

  content = IO.read(test_var)

  assert content == 'bar'  
end

Then /^the migration metadata will be cleaned up$/ do 
  assert Dir.glob(File.join($home_root, @app.uid, 'data', '.migration*')).empty?
  assert_file_not_exists File.join($home_root, @app.uid, 'app-root', 'runtime', '.premigration_state')
end

Then /^the (mysql|mongodb) uservars entries will be migrated to a namespaced env directory$/ do |cart|
  cart_namespaced_dir = File.join($home_root, @app.uid, '.env', cart)

  vars = %w(USERNAME PASSWORD HOST PORT URL GEAR_UUID GEAR_DNS).map { |x| "OPENSHIFT_#{cart.upcase}_DB_#{x}"}

  vars.each do |var|
    assert_file_exists File.join(cart_namespaced_dir, var)
  end
end