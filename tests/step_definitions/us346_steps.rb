require 'rubygems'
require 'net/http'
require 'uri'
require 'mechanize'
include Libra::Test::User
include Libra::Test::Util

Then /^users are able to create new rails app using rails new$/ do
  # Generate the 'product' of namespace / app combinations
  user_apps = @namespaces.product(@apps)

  # Make a change and push it
  urls = {}
  user_apps.each do |user_app|
    repo = "#{$temp}/#{user_app[0]}_#{user_app[1]}_repo"
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

    host = "#{user_app[1]}-#{user_app[0]}.#{$domain}"
    $logger.info("host= #{host}")
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
      $logger.error "Exception trying to access #{host}"
      $logger.error "Response code = #{code}"
      $logger.error e.message
      $logger.error e.backtrace
      code = -1
    end

    # Store the results
    urls[host] = code
  end

  # Print out the results:
  #  Format = code - url
  $logger.info("Change Results")
  urls.each_pair do |url, code|
    $logger.info("#{code} - #{url}")
  end

  # Get all the unique responses
  # There should only be 1 result ["200"]
  uniq_responses = urls.values.uniq
  uniq_responses.length.should == 1
  uniq_responses[0].should == "200"
end

