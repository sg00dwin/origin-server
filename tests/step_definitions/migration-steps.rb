When /^the application is migrated to the v2 cartridge system$/ do
  output = `rhc-admin-migrate --app-name #{@app.name} --login #{@app.login} --migrate-gear #{@app.uid} --version 2.0.28`

  $logger.info("Migration output: #{output}")

  assert_equal 0, $?.exitstatus
end

Then /^the environment variables will be migrated to raw values$/ do
  Dir.glob(File.join($home_root, @app.uid, '.env', '*')).each do |entry|
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
