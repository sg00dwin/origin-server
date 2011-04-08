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
    app_name = user_app[0]+"_"+user_app[1]

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

    $logger.info("host= #{url}")
    begin
      res = Net::HTTP.start(host, 80) do |http|
        http.read_timeout = 30
        http.get("/")
      end

      # Store the response code for later use
      code = res.code

      # Verify the content of the response
      res.body.index("TEST").should_not == -1
    rescue Exception => e
      $logger.error "Exception trying to access #{url}"
      $logger.error e.message
      $logger.error e.backtrace
      code = -1
    end

    # Store the results
    value[:change_code] = code
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
  # There should only be 1 result ["200"]
  uniq_responses = results.uniq
  uniq_responses.length.should == 1
  uniq_responses[0].should == "200"
end

