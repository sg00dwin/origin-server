require 'rubygems'
require 'uri'

include AppHelper

Given /^an existing (.+) application$/ do |type|
  TestApp.find_on_fs.each do |app|
    if app.type == type
      @app = app
      break
    end
  end
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

When /^that application is changed$/ do
  Dir.chdir(@app.repo)
  @update = "TEST"

  # Make a change to the app index file
  run("sed -i 's/Welcome/#{@update}/' #{@app.get_index_file}")
  run("git commit -a -m 'Test change'")
  run("git push >> " + @app.get_log("git_push") + " 2>&1")
end

When /^that application is stopped$/ do
  rhc_ctl_stop(@app)
end

When /^that application is started$/ do
  rhc_ctl_start(@app)
end

When /^that application is restarted$/ do
  rhc_ctl_restart(@app)
end

When /^that application is destroyed$/ do
  rhc_ctl_destroy(@app)
end

Then /^they should be accessible?$/ do
  @apps.each do |app|
    app.is_accessible?.should be_true
    app.is_accessible?(true).should be_true
  end
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

Then /^it should be accessible$/ do
  @app.is_accessible?.should be_true
  @app.is_accessible?(true).should be_true
end

Then /^it should not be accessible$/ do
  @app.is_inaccessible?.should be_true
end
