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
  @table = table
  @data = {}
end

Given /^a (\d+) second command timeout$/ do |timeout|
  @cmd_timeout = timeout.to_i
end

Given /^a (\d+) second http request timeout$/ do |timeout|
  @http_timeout = timeout.to_i
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

  @table.hashes.each do |row|
    max_processes = row['processes'].to_i
    namespaces = Array.new(row['users'].to_i)
    apps = (row['apps'].to_i).times.collect{|num| "app#{num}" }
    type = row['type']

    # Limit loop on the number of namespaces established in a previous step
    namespaces.each_with_index do |data, index|
      # Get a unique namespace to create in the forked process
      # and add it to the list of reserved namespaces to avoid
      # race conditions of duplicate users
      info = get_unique_username(namespaces)
      namespace = info[:namespace]
      login = info[:login]
      namespaces[index] = namespace

      # Store the data for the app (can't do this within the fork)
      apps.each do |app|
        # Store the generated data for the other tests to verify
        url = "#{app}-#{namespace}.#{$domain}"
        @data[url] = {:namespace => namespace, :app => app, :type => type}
      end

      # Create the users in subprocesses
      # Count the current sub processes
      # if at max, wait for some to finish and keep going

      processes << fork do
        login = "libra-test+#{namespace}@redhat.com"
        # Create the user and the apps
        run("#{$create_domain_script} -n #{namespace} -l #{login} -p fakepw -d")
        apps.each do |app|
          # Now create the app
          run("#{$create_app_script} -l #{login} -a #{app} -r #{$temp}/#{namespace}_#{app}_repo -t #{type} -p fakepw -d")
        end
      end

      # Wait for some process to complete if necessary
      Timeout::timeout(@cmd_timeout || 300) do
        pid = processes.shift
        Process.wait(pid)
        $logger.error("Process #{pid} failed") if $?.exitstatus != 0
      end if processes.length >= max_processes

      # sleep a little to randomize forks
      sleep rand
    end
  end

  # Wait for the remaining processes
  processes.reverse.each do |pid|
    Timeout::timeout(@cmd_timeout || 300) do
      Process.wait(pid)
      $logger.error("Process #{pid} failed") if $?.exitstatus != 0
    end
  end
end

Then /^they should all be accessible$/ do
  # Hit the health check page for each app
  @data.each_pair do |url, value|
    begin
      $logger.info("Checking host #{url}")
      res = Net::HTTP.start(url, 80) do |http|
        http.read_timeout = @http_timeout || 60
        http.get("/health_check.php")
      end
      code = res.code
    rescue Exception => e
      $logger.error "Exception trying to access #{url}"
      $logger.error e.message
      $logger.error e.backtrace
      code = -1
    end

    # Store the results
    value[:code] = code
  end

  # Print out the results:
  #  Format = code - url
  $logger.info("Accessibility Results")
  results = []
  @data.each_pair do |url, value|
    $logger.info("#{value[:code]} - #{url} (#{value[:type]})")
    results << value[:code]
  end

  # Get all the unique responses
  # There should only be 1 result ["200"]
  uniq_responses = results.uniq
  uniq_responses.length.should == 1
  uniq_responses[0].should == "200"
end


Then /^they should be able to be changed$/ do
  @data.each_pair do |url, value|
    repo = "#{$temp}/#{value[:namespace]}_#{value[:app]}_repo"
    $logger.info("Changing to dir=#{repo}")
    Dir.chdir(repo)

    app_file = case value[:type]
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

    $logger.info("host= #{url}")
    begin
      res = Net::HTTP.start(url, 80) do |http|
        http.read_timeout = @http_timeout || 60
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
  $logger.info("Accessibility Results")
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

Then /^no errors should be thrown$/ do
end
