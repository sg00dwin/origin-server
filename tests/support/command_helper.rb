require 'open4'
require 'timeout'

module CommandHelper
  #
  # Run a command with logging.  If the command
  # returns a non-zero error code, raise an exception
  #
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
  def runcon(cmd, user=nil, role=nil, type=nil)
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
    $logger.info("Standard Output:\n#{outstring}")
    $logger.info("Standard Error:\n#{errstring}")

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
  end
end
World(CommandHelper)
