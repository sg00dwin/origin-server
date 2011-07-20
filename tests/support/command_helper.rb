require 'open4'
require 'timeout'
require 'fileutils'

module CommandHelper
  def run_stdout(cmd)
    $logger.info("Running: #{cmd}")

    pid, stdin, stdout, stderr = Open4::popen4(cmd)
    stdin.close

    exit_code = -1
    output = nil
    
    # Don't let a command run more than 5 minutes
    Timeout::timeout(500) do
      ignored, status = Process::waitpid2 pid
      exit_code = status.exitstatus
      output = stdout.read
    end

    $logger.error("(#{$$}): Execution failed #{cmd} with exit_code: #{exit_code.to_s}") if exit_code != 0
    return output
  end

  def run(cmd)
    $logger.info("Running: #{cmd}")

    pid, stdin, stdout, stderr = Open4::popen4(cmd)
    stdin.close

    exit_code = -1

    # Don't let a command run more than 5 minutes
    Timeout::timeout(500) do
      ignored, status = Process::waitpid2 pid
      exit_code = status.exitstatus

      $logger.info("Standard Output:\n#{stdout.read}")
      $logger.info("Standard Error:\n#{stderr.read}")
    end

    $logger.error("(#{$$}): Execution failed #{cmd} with exit_code: #{exit_code.to_s}") if exit_code != 0
    return exit_code
  end

  # run a command in an alternate SELinux context
  def runcon(cmd, user=nil, role=nil, type=nil, outbuf=nil)
    prefix = 'runcon'
    prefix += (' -u ' + user) if user
    prefix += (' -r ' + role) if role
    prefix += (' -t ' + type) if type
    fullcmd = prefix + " " + cmd

    pid, stdin, stdout, stderr = Open4::popen4(fullcmd)

    stdin.close
    ignored, status = Process::waitpid2 pid
    exit_code = status.exitstatus

    outstring = stdout.read
    errstring = stderr.read
    $logger.debug("Standard Output:\n#{outstring}")
    $logger.debug("Standard Error:\n#{errstring}")
    # append the buffers if an array container is provided
    if outbuf
      outbuf << outstring
      outbuf << errstring
    end

    $logger.error("(#{$$}): Execution failed #{cmd} with exit_code: #{exit_code.to_s}") if exit_code != 0

    return exit_code
  end

  def rhc_create_domain(app)
    exit_code = run("#{$create_domain_script} -n #{app.namespace} -l #{app.login} -p fakepw -d")
    app.create_domain_code = exit_code
    exit_code == 0
  end

  def rhc_create_app(app)
    exit_code = run("#{$create_app_script} -l #{app.login} -a #{app.name} -r #{app.repo} -t #{app.type} -p fakepw -d")
    app.create_app_code = exit_code
    return app
  end

  def rhc_embed_add(app, type)
    result = run_stdout("#{$ctl_app_script} -l #{app.login} -a #{app.name} -p fakepw -e add-#{type} -d")
    app.mysql_hostname = /^Connection URL: mysql:\/\/(.*)\/$/.match(result)[1]
    app.mysql_user = /^ +Root User: (.*)$/.match(result)[1]
    app.mysql_password = /^ +Root Password: (.*)$/.match(result)[1]

    app.mysql_hostname.should_not be_nil
    app.mysql_user.should_not be_nil
    app.mysql_password.should_not be_nil

    app.embed = type
    app.persist
    return app
  end

  def rhc_embed_remove(app)
    run("#{$ctl_app_script} -l #{app.login} -a #{app.name} -p fakepw -e remove-#{app.embed} -d").should == 0
    app.mysql_hostname = nil
    app.mysql_user = nil
    app.mysql_password = nil
    app.embed = nil
    app.persist
    return app
  end

  def rhc_ctl_stop(app)
    run("#{$ctl_app_script} -l #{app.login} -a #{app.name} -p fakepw -c stop -d").should == 0
    run("#{$ctl_app_script} -l #{app.login} -a #{app.name} -p fakepw -c status | grep '#{app.get_stop_string}'").should == 0
  end

  def rhc_ctl_start(app)
    run("#{$ctl_app_script} -l #{app.login} -a #{app.name} -p fakepw -c start -d").should == 0
    run("#{$ctl_app_script} -l #{app.login} -a #{app.name} -p fakepw -c status | grep '#{app.get_stop_string}'").should == 1
  end

  def rhc_ctl_restart(app)
    run("#{$ctl_app_script} -l #{app.login} -a #{app.name} -p fakepw -c restart -d").should == 0
    run("#{$ctl_app_script} -l #{app.login} -a #{app.name} -p fakepw -c status | grep '#{app.get_stop_string}'").should == 1
  end

  def rhc_ctl_destroy(app)
    run("#{$ctl_app_script} -l #{app.login} -a #{app.name} -p fakepw -c destroy -b -d").should == 0
    run("#{$ctl_app_script} -l #{app.login} -a #{app.name} -p fakepw -c status | grep 'not found'").should == 0
    FileUtils.rm_rf app.repo
    FileUtils.rm_rf app.file
  end

  #
# useful methods to avoid duplicating effort
#

  #
  # Count the number of processes owned by account with cmd_name 
  #
  def num_procs acct_name, cmd_name
    
    ps_pattern = /^(\d+)\s+(\S+)$/
    command = "ps --no-headers -o pid,comm -u #{acct_name}"
    $logger.debug("num_procs: executing #{command}")
    
    pid, stdin, stdout, stderr = Open4::popen4(command)
    
    stdin.close
    ignored, status = Process::waitpid2 pid
    exit_code = status.exitstatus

    outstrings = stdout.readlines
    errstrings = stderr.readlines
    $logger.debug("looking for #{cmd_name}")
    $logger.debug("ps output:\n" + outstrings.join("")) 

    proclist = outstrings.collect { |line|
      match = line.match(ps_pattern)
      match and (match[1] if match[2] == cmd_name)
    }.compact!

    found = proclist ? proclist.size : 0
    $logger.debug("Found = #{found} instances of #{cmd_name}")
    found
  end

end
World(CommandHelper)
