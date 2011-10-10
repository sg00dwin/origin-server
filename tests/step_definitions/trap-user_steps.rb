#
#
#
#require 'open4'
require 'pty'

Given /^the user creates a new( (\S+))? application$/ do |ignore, app_type|
  app_type = "php-5.3" unless app_type
  @namespace = @info[:namespace]
  @app_name = @namespace
  @repo_path="#{$temp}/#{@namespace}_#{@namespace}_repo"

  # set the domain into the default user's account
  domain_output = []
  command = "#{$create_domain_script} -n #{@namespace} -l #{@rhc_login} -p fakepw -d"
  begin
    exit_status = run(command, domain_output)
    raise Exception.new "exit status #{exit_status} from '#{command}'" if exit_status != 0
  rescue Exception => e
    puts "create domain failed once: trying again in 10 sec"
    sleep 10
    exit_status = run(command, domain_output)
    raise Exception.new "exit status #{exit_status} from '#{command}'" if exit_status != 0
  end
    
  # create the app on an available node
  app_output = []
  command = "#{$create_app_script} -a #{@app_name} -l #{@rhc_login} -r #{@repo_path} -t #{app_type} -p fakepw -d"
  begin
    exit_status = run(command, app_output)
    raise Exception.new "exit status #{exit_status} from '#{command}'" if exit_status != 0
  rescue Exception => e
    puts e.message
    puts "create app failed once: trying again in 10 sec"
    sleep 10
    exit_status = run(command, app_output)
    raise Exception.new "exit status #{exit_status} from '#{command}'" if exit_status != 0
  end

  # find the application account name and host
  ssh_pattern = %r|ssh://([^@]+)@([^/]+)|
    
  match = app_output[0].map { |line| line.match(ssh_pattern)}.compact[0]
  raise Exception.new "no ssh line for application" unless match
  @acct_name = match[1]
  @hostname = match[2]
end

Given /^the user has (no|\d+) tail process(es)? running( in (\d+) seconds)?$/ do |expect, ignore1, ignore2, timeout|
  # convert to integer
  expect = (expect == "no" ? 0 : expect.to_i)
  timeout = timeout ? timeout.to_i : 0
  sleep timeout
  pcount = num_procs @acct_name, "tail"

  if pcount != expect
    raise Cucumber::Pending.new "failed given: expected #{expect}, actual #{pcount}" 
  end
end

Given /a running SSH log stream/ do
  ssh_cmd = "ssh -t #{@acct_name}@#{@hostname} tail -f #{@app_name}/logs/\\*"

  #puts "calling #{ssh_cmd}"

  #pid, stdin, stdout, stderr = Open4::popen4(ssh_cmd)
  stdout, stdin, pid = PTY.spawn ssh_cmd
  #stdin.close

  @ssh_cmd = {
    :pid => pid,
    :stdin => stdin,
    :stdout => stdout,
    #:stderr => stderr
  }

end

Given /I wait (\d+) second(s)?$/ do |sec, ignore|
  sleep(sec.to_i)
end

When /^I request the logs via SSH$/ do
  ssh_cmd = "ssh -t #{@acct_name}@#{@hostname} tail -f #{@app_name}/logs/\\*"

  stdout, stdin, pid = PTY.spawn ssh_cmd

  @ssh_cmd = {
    :pid => pid,
    :stdout => stdout,
  }
end

When /^I terminate the SSH log stream$/ do
  begin
    # check if the PID still exists
    Process.kill("TERM", @ssh_cmd[:pid])
    exit_code = -1

    # Don't let a command run more than 5 minutes
    Timeout::timeout(600) do
      ignored, status = Process::waitpid2 @ssh_cmd[:pid]
      exit_code = status.exitstatus
    end
  rescue PTY::ChildExited
    # Completed as expected
  end

  outstring = @ssh_cmd[:stdout].read
  $logger.debug("Standard Output:\n#{outstring}")
end


Then /^there will be (no|\d+) tail processes running( in (\d+) seconds)?$/ do |expect, ignore, timeout|
  # convert to integer
  expect = (expect == "no" ? 0 : expect.to_i)
  timeout = timeout ? timeout.to_i : 0
  sleep timeout
  pcount = num_procs @acct_name, "tail"
  pcount.should be == expect
end
