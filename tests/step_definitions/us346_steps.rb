require 'rubygems'
require 'net/http'
require 'uri'
require 'mechanize'
include Libra::Test::User
include Libra::Test::Util

Then /^users are able to create new rails app using rails new$/ do
  # Hit the health check page for each app
  @data.each_pair do |url, value|
    repo = "#{$temp}/#{value[:namespace]}_#{value[:app]}_repo"
    $logger.info("Changing to dir=#{repo}")
    Dir.chdir(repo)

    app_file = "public/index.html"    
    app_name = value[:app]

    #Create new rails app
    run("rails new #{app_name}")
    Dir.chdir(repo+"/#{app_name}")
    run("sed -i 's/Welcome/TEST/' #{app_file}")
    run("bundle install")
    Dir.chdir(repo)
    run("cp -r #{app_name}/* .")

    run("rm -rf #{app_name}/")


    #commit
    run("git add .")
    run("git commit -m 'Add rails app'")
    run("git push")


    # Allow change to be loaded
    sleep 30

    connect(url, "/", @http_timeout) do |code, time, body|
      value[:change_code] = code
      if body
        body.index("TEST").should_not == -1
      end
    end
  end

  # Print out the results:
  #  Format = code - url
  $logger.info("Rails App Results")
  results = []
  @data.each_pair do |url, value|
    $logger.info("#{value[:change_code]} - #{url} (#{value[:type]})")
    results << value[:change_code]
  end

  # Get all the unique responses
  # There should only be 1 result [0]
  uniq_responses = results.uniq
  uniq_responses.length.should == 1
  uniq_responses[0].should == 0
end

Then /^they should all be accessible within (\d+) seconds$/ do |timeout|
  # Hit the health check page for each app
  @data.each_pair do |url, value|
    connect(url, "/config.ru", timeout.to_i) do |code, time, body|
      value[:code] = code
      value[:time] = time
    end unless value[:failed]
  end

  # Print out the results:
  #  Format = code - url
  $logger.info("Accessibility Results")
  results = []
  @data.each_pair do |url, value|
    $logger.info("#{value[:code]} / #{value[:time]} - #{url} (#{value[:type]})")
    results << value[:code]
  end

  # Get all the unique responses
  # There should only be 1 result [0]
  uniq_responses = results.uniq
  uniq_responses.length.should == 1
  uniq_responses[0].should == 0
end

