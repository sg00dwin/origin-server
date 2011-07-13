require 'rubygems'
require 'uri'
require 'fileutils'

include AppHelper

Given /^an existing (.+) application with an embedded (.*) cartridge$/ do |type, embed|
  TestApp.find_on_fs.each do |app|
    if app.type == type and app.embed == embed
      @app = app
      break
    end
  end

  @app.should_not be_nil
end

Given /^an existing (.+) application( without an embedded cartridge)?$/ do |type, ignore|
  TestApp.find_on_fs.each do |app|
    if app.type == type and !app.embed
      @app = app
      break
    end
  end

  @app.should_not be_nil
end

When /^(\d+) (.+) applications are created$/ do |app_count, type|
  # Create our domain and apps
  @apps = app_count.to_i.times.collect do
    app = TestApp.create_unique(type)
    if rhc_create_domain(app)
      rhc_create_app(app)
    end
    app
  end
end

When /^the embedded (.*) cartridge is added$/ do |type|
  rhc_embed_add(@app, type)
end

When /^the embedded cartridge is removed$/ do
  rhc_embed_remove(@app)
end

When /^the application is changed$/ do
  Dir.chdir(@app.repo) do
    @update = "TEST"
  
    # Make a change to the app index file
    run("sed -i 's/Welcome/#{@update}/' #{@app.get_index_file}")
    run("git commit -a -m 'Test change'")
    run("git push >> " + @app.get_log("git_push") + " 2>&1")
  end
end

When /^the application uses mysql$/ do
  Dir.chdir(@app.repo) do
    # Copy the MySQL file over the index and replace the variables
    FileUtils.cp @app.get_mysql_file, @app.get_index_file
  
    # Make a change to the app index file
    run("sed -i 's/HOSTNAME/#{@app.mysql_hostname}/' #{@app.get_index_file}")
    run("sed -i 's/USER/#{@app.mysql_user}/' #{@app.get_index_file}")
    run("sed -i 's/PASSWORD/#{@app.mysql_password}/' #{@app.get_index_file}")
    run("git commit -a -m 'Test change'")
    run("git push >> " + @app.get_log("git_push_mysql") + " 2>&1")
  end
end

When /^the application is stopped$/ do
  rhc_ctl_stop(@app)
end

When /^the application is started$/ do
  rhc_ctl_start(@app)
end

When /^the application is restarted$/ do
  rhc_ctl_restart(@app)
end

When /^the application is destroyed$/ do
  rhc_ctl_destroy(@app)
end

Then /^the applications should be accessible?$/ do
  @apps.each do |app|
    app.is_accessible?.should be_true
    app.is_accessible?(true).should be_true
  end
end

Then /^the mysql response is successful$/ do
    @app.connect.should match(/Success/)
end

Then /^it should be updated successfully$/ do
  60.times do |i|
    body = @app.connect
    break if body and body =~ /#{@update}/
    sleep 1
  end

  # Make sure the update is present
  body = @app.connect
  body.should_not be_nil
  body.should match(/#{@update}/)
end

Then /^the application should be accessible$/ do
  @app.is_accessible?.should be_true
  @app.is_accessible?(true).should be_true
end

Then /^the application should not be accessible$/ do
  @app.is_inaccessible?.should be_true
end
