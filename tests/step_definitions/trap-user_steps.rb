require 'pty'
require 'digest/md5'

ssh = %{ssh -o BatchMode=yes \
                 -o StrictHostKeyChecking=no \
                 -t}


Given /^the user has (no|\d+) tail process(es)? running( in (\d+) seconds)?$/ do |expect, ignore1, ignore2, timeout|
  # convert to integer
  expect = (expect == "no" ? 0 : expect.to_i)
  timeout = timeout ? timeout.to_i : 0
  sleep timeout
  pcount = num_procs @app.uid, "tail"

  if pcount != expect
    raise Cucumber::Pending.new "failed given: expected #{expect}, actual #{pcount}" 
  end
end

Given /a running SSH log stream/ do
  ssh_cmd = "ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -t #{@app.uid}@#{@app.hostname} tail -f #{@app.name}/logs/\\*"

  stdout, stdin, pid = PTY.spawn ssh_cmd

  @ssh_cmd = {
    :pid => pid,
    :stdin => stdin,
    :stdout => stdout,
  }

end

Given /I wait (\d+) second(s)?$/ do |sec, ignore|
  sleep(sec.to_i)
end

When /^I request the logs via SSH$/ do
  ssh_cmd = "ssh  -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -t #{@app.uid}@#{@app.hostname} tail -f #{@app.name}/logs/\\*"

  stdout, stdin, pid = PTY.spawn ssh_cmd

  @ssh_cmd = {
    :pid => pid,
    :stdout => stdout,
  }
end

Then /^I can obtain disk quota information via SSH$/ do
  ssh_cmd = "ssh  -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -t #{@app.uid}@#{@app.hostname} /usr/bin/quota"
  buf=""
  begin
    stdout, stdin, pid = PTY.spawn ssh_cmd
    Timeout::timeout(600) do
      buf=stdout.read
    end
    # PTY.check(pid, true)
    Process.kill("KILL", pid)
  rescue PTY::ChildExited, Errno::ESRCH
  end
  if buf.index("Disk quotas for user #{@app.uid}").nil?
    raise "Could not obtain disk quota information"
  end
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
  pcount = num_procs @app.uid, "tail"
  pcount.should be == expect
end

Then /^I can run "([^\"]*)" with exit code: (\d+)/ do |cmd, code|
  ssh_call = ssh + " #{@app.uid}@#{@app.hostname} " + cmd
  exit_code = runcon ssh_call, 'unconfined_u', 'unconfined_r', 'unconfined_t'
  raise "#{cmd} Failed with exit: #{exit_code} (expected #{code})" \
    unless exit_code.to_i == code.to_i
end

Then /^I can use the rhcsh menus/ do
  welcome_md5 = "ce7c4f0f3d14e6e01034b5b5e81a75b7"
  help_md5 = "86b07610d595392edbe66f59d579c702"

  # Check the welcome menu
  outbuf = []
  ssh_call = ssh + " #{@app.uid}@#{@app.hostname} " + "rhcsh true"
  exit_code = runcon ssh_call, 'unconfined_u', 'unconfined_r', 'unconfined_t', outbuf
  out = outbuf[0].split(/Connection to/)[0]
  md5 = Digest::MD5.hexdigest(out)
  $logger.debug("MD5sum check for welcome message:")
  $logger.debug("was: #{md5} expected: #{welcome_md5}")
  raise "md5sum of welcome message did not match.  Update: trap-user_steps.rb\n" +
    "was: #{md5} expected: #{welcome_md5}" unless md5 == welcome_md5

  # Check the help menu
  outbuf = []
  ssh_call = ssh + " #{@app.uid}@#{@app.hostname} " + "rhcsh help"
  exit_code = runcon ssh_call, 'unconfined_u', 'unconfined_r', 'unconfined_t', outbuf
  out = outbuf[0].split(/Connection to/)[0]
  md5 = Digest::MD5.hexdigest(out)
  $logger.debug("MD5sum check for help message:")
  $logger.debug("was: #{md5} expected: help_md5")
  raise "md5sum of help message did not match.  Update: trap-user_steps.rb\n" +
    "was: #{md5} expected: #{help_md5}" unless md5 == help_md5

end
