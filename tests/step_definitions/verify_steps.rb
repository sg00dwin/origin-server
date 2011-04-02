require 'rubygems'
require 'net/http'
require 'uri'
require 'mechanize'
include Libra::Test::User
include Libra::Test::Util

Given /^the libra client tools$/ do
  File.exists?($create_app_script).should be_true
  File.exists?($create_domain_script).should be_true
  File.exists?($client_config).should be_true
end

Given /^the following test data$/ do |table|
  table.hashes.each do |row|
    @max_processes = row['processes'].to_i
    @namespaces = Array.new(row['users'].to_i)
    @apps = (row['apps'].to_i).times.collect{|num| "app#{num}" }
    @type = row['type']
  end
end

Given /^the following website links$/ do |table|
  @agent = Mechanize.new { |agent|
    agent.user_agent_alias = 'Mac Safari'
    if ENV['http_proxy']
      print("(using proxy)")
      uri = URI.parse(ENV['http_proxy'])
      agent.set_proxy(uri.host, uri.port)
    end
  }

  @urls = []
  table.hashes.each do |row|
    @urls << "#{row['protocol']}://localhost#{row['uri']}"
  end
end

When /^they are accessed$/ do
  @urls.each do |url|
    @agent.get(url)
  end
end

When /^the applications are created$/ do
  processes = []

  # Limit loop on the number of namespaces established in a previous step
  @namespaces.each_with_index do |data, index|
    # Get a unique namespace to create in the forked process
    # and add it to the list of reserved namespaces to avoid
    # race conditions of duplicate users
    info = get_unique_username(@namespaces)
    namespace = info[:namespace]
    login = info[:login]
    @namespaces[index] = namespace

    # Create the users in subprocesses
    # Count the current sub processes
    # if at max, wait for some to finish and keep going

    processes << fork do
      login = "libra-test+#{namespace}@redhat.com"
      # Create the user and the apps
      run("#{$create_domain_script} -n #{namespace} -l #{login} -p fakepw -d")
      @apps.each do |app|
        run("#{$create_app_script} -l #{login} -a #{app} -r #{$temp}/#{namespace}_#{app}_repo -t #{@type} -p fakepw -d")
      end
    end

    # Wait for some process to complete if necessary
    Timeout::timeout(300) do
      pid = processes.shift
      Process.wait(pid)
      $logger.error("Process #{pid} failed") if $?.exitstatus != 0
    end if processes.length >= @max_processes

    # sleep a little to randomize forks
    sleep rand
  end

  # Wait for the remaining processes
  processes.reverse.each do |pid|
    Timeout::timeout(300) do
      Process.wait(pid)
      $logger.error("Process #{pid} failed") if $?.exitstatus != 0
    end
  end
end

Then /^they should all be accessible$/ do
  # Generate the 'product' of namespace / app combinations
  user_apps = @namespaces.product(@apps)

  urls = {}
  # Hit the health check page for each app
  user_apps.each do |user_app|
    # Make sure to handle timeouts
    host = "#{user_app[1]}-#{user_app[0]}.#{$domain}"
    begin
      $logger.info("Checking host #{host}")
      res = Net::HTTP.start(host, 80) do |http|
        http.read_timeout = 60
        http.get("/health_check.php")
      end
      code = res.code
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
  $logger.info("Accessibility Results")
  urls.each_pair do |url, code|
    $logger.info("#{code} - #{url}")
  end

  # Get all the unique responses
  # There should only be 1 result ["200"]
  uniq_responses = urls.values.uniq
  uniq_responses.length.should == 1
  uniq_responses[0].should == "200"
end


Then /^they should be able to be changed$/ do
  # Generate the 'product' of namespace / app combinations
  user_apps = @namespaces.product(@apps)

  # Make a change and push it
  urls = {}
  user_apps.each do |user_app|
    repo = "#{$temp}/#{user_app[0]}_#{user_app[1]}_repo"
    $logger.info("Changing to dir=#{repo}")
    Dir.chdir(repo)

    app_file = case @type
      when "php-5.3.2" then "php/index.php"
      when "rack-1.1.0" then "config.ru"
      when "wsgi-3.2.1" then "wsgi/application"
    end

    # Make a change to the app
    run("sed -i 's/Welcome/TEST/' #{app_file}")
    run("git commit -a -m 'Test change'")
    run('git push')

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

Then /^no errors should be thrown$/ do
end
