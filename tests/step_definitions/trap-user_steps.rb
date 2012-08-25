require 'pty'
require 'digest/md5'

ssh = %{ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q }


Given /^the user has (no|\d+) tail process(es)? running( in (\d+) seconds)?$/ do |expect, ignore1, ignore2, timeout|
  # convert to integer
  expect = (expect == "no" ? 0 : expect.to_i)
  timeout = timeout ? timeout.to_i : 1

  pcount = num_procs @app.uid, "tail"
  StickShift::timeout(timeout) do
    while pcount != expect
      sleep 1
      pcount = num_procs @app.uid, "tail"
    end
  end
  assert_equal pcount, expect, "Wrong number of tail processes" 
end

Given /a running SSH log stream/ do
  ssh_cmd = ssh + "-t #{@app.uid}@#{@app.hostname} tail -f #{@app.name}/logs/\\*"
  stdout, stdin, pid = PTY.spawn ssh_cmd

  @ssh_cmd = {
    :pid => pid,
    :stdin => stdin,
    :stdout => stdout,
  }

end

When /^I request the logs via SSH$/ do
  ssh_cmd = ssh + " #{@app.uid}@#{@app.hostname} tail -f #{@app.name}/logs/\\*"
  stdout, stdin, pid = PTY.spawn ssh_cmd

  @ssh_cmd = {
    :pid => pid,
    :stdout => stdout,
  }
end

Then /^I can obtain disk quota information via SSH$/ do
  outbuf=[]
  ssh_call = ssh + " #{@app.uid}@#{@app.hostname} /usr/bin/quota"
  exit_code = runcon ssh_call, 'unconfined_u', 'unconfined_r', 'unconfined_t', outbuf
  if outbuf.join(" ").index("Disk quotas for user #{@app.uid}").nil?
    raise "Could not obtain disk quota information"
  end
end

When /^I terminate the SSH log stream$/ do
  begin
    # check if the PID still exists
    Process.kill("INT", @ssh_cmd[:pid])
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
  $logger.info("Standard Output:\n#{outstring}")
end

Then /^I can run "([^\"]*)" with exit code: (\d+)/ do |cmd, code|
  ssh_call = ssh + " #{@app.uid}@#{@app.hostname} " + cmd
  exit_code = runcon ssh_call, 'unconfined_u', 'unconfined_r', 'unconfined_t'
  raise "#{cmd} Failed with exit: #{exit_code} (expected #{code})" \
    unless exit_code.to_i == code.to_i
end


def run_pty_command(cmd, outbuf=[], timeout=600)
  $logger.info("Running: #{cmd}")

  output=''
  begin
    stdout, stdin, pid = PTY.spawn cmd
    Timeout::timeout(timeout) do
      output += stdout.read
    end

    ignored, status = Process::waitpid2 pid
    exit_code = status.exitstatus
  rescue PTY::ChildExited
    $logger.info("PTY::ChildExited CMD: #{cmd}")
  rescue Timeout::ERROR
    $logger.error("Timeout reached for command: CMD: #{cmd}  PID: #{pid}")
    Process.kill("KILL", pid)
  end

  outbuf << output
  $logger.info("Output:\n#{output}")
  return exit_code
end

Then /^I can get the rhcsh splash/ do
  welcome_md5 = "64d5a2701b7dec2ce0a16d39f6041110"

  # Check the welcome menu
  outbuf = []
  ssh_call = ssh + "-t #{@app.uid}@#{@app.hostname} " + "rhcsh true"
  exit_code = run_pty_command ssh_call, outbuf
  out = outbuf[0].split(/Connection to/)[0]
  md5 = Digest::MD5.hexdigest(out)
  assert_equal md5, welcome_md5, '"md5sum of welcome message did not match.'
end

Then /^I can get the rhcsh help/ do
  help_md5 = "e6567b42926432fc97f720dc0f86d6f3"

  # Check the help menu
  outbuf = []
  ssh_call = ssh + "-t #{@app.uid}@#{@app.hostname} " + "rhcsh help"
  exit_code = run_pty_command ssh_call, outbuf
  out = outbuf[0]
  md5 = Digest::MD5.hexdigest(out)
  assert_equal md5, help_md5, "md5sum of help message did not match."
end
