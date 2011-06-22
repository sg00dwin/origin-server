require 'rubygems'
require 'net/http'
require 'uri'
require 'mechanize'
include Libra::Test::User
include Libra::Test::Util

Given /^an accepted node$/ do
  accept_node = "/usr/bin/rhc-accept-node"
  File.exists?(accept_node).should be_true

  pass = `#{accept_node}`.chomp
  $?.exitstatus.should be(0)
  pass.should == "PASS"
end

Given /^the libra client tools$/ do
  File.exists?($create_app_script).should be_true
  File.exists?($create_domain_script).should be_true
  File.exists?($client_config).should be_true
  File.exists?($ctl_app_script).should be_true
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
  urls_by_pid = {}
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
      urls = []

      # Store the data for the app (can't do this within the fork)
      apps.each do |app|
        # Store the generated data for the other tests to verify
        url = "#{app}-#{namespace}.#{$domain}"
        urls << url
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
          repo = "#{$temp}/#{namespace}_#{app}_repo"
          command = "#{$create_app_script} -l #{login} -a #{app} -r #{repo} -t #{type} -p fakepw -d"
          exit_code = run(command)

          # Safely append to a file all the url's that failed and succeeded
          url = "#{app}-#{namespace}.#{$domain}"
          if exit_code != 0
            add_failure(url)
          else
            add_success(url)
          end
        end
      end

      # Store the urls for the process
      urls_by_pid[processes.last] = urls

      # Wait for some process to complete if necessary
      if processes.length >= max_processes
        wait(processes.pop, urls, @cmd_timeout)
      end

      # sleep a little to randomize forks
      sleep rand
    end
  end

  # Wait for the remaining processes
  processes.reverse.each do |pid|
    wait(pid, urls_by_pid[pid], @cmd_timeout)
  end
  
  # Fill out the data structure for all failures
  unless failures.nil?
    failures.each do |url|
      if @data[url]
        @data[url][:failed] = true
        @data[url][:code] = -1
        @data[url][:time] = -1
      else
        $logger.info("Failure url not found: #{url}")
      end  
    end
  end
end

Then /^they should all be accessible$/ do
  # Hit the health check page for each app
  @data.each_pair do |url, value|
    connect(url, "/health_check.php", @http_timeout) do |code, time, body|
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


Then /^they should be able to be changed$/ do
  @data.each_pair do |url, value|
    repo = "#{$temp}/#{value[:namespace]}_#{value[:app]}_repo"
    $logger.info("Changing to dir=#{repo}")
    Dir.chdir(repo)

    app_file = case value[:type]
      when "php-5.3" then "php/index.php"
      when "rack-1.1" then "config.ru"
      when "wsgi-3.2" then "wsgi/application"
      when "perl-5.10" then "perl/index.pl"
      when "jbossas-7.10" then "deployments/ROOT.war/index.html"
    end

    # Make a change to the app
    run("sed -i 's/Welcome/TEST/' #{app_file}")
    run("git commit -a -m 'Test change'")
    run('git push')

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
  $logger.info("Accessibility Results")
  results = []
  @data.each_pair do |url, value|
    $logger.info("#{value[:change_code]} / #{value[:time]} - #{url} (#{value[:type]})")
    results << value[:change_code]
  end

  # Get all the unique responses
  # There should only be 1 result [0]
  uniq_responses = results.uniq
  uniq_responses.length.should == 1
  uniq_responses[0].should == 0
end

Then /^no errors should be thrown$/ do
end
