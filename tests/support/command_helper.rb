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

  def run(cmd, outbuf=[], retrying=false)
    $logger.info("Running: #{cmd}")

    pid, stdin, stdout, stderr = Open4::popen4(cmd)
    stdin.close

    exit_code = -1
    # Don't let a command run more than 5 minutes
    Timeout::timeout(500) do
      ignored, status = Process::waitpid2 pid
      exit_code = status.exitstatus
    end

    outstring = stdout.read
    errstring = stderr.read
    $logger.debug("Standard Output:\n#{outstring}")
    $logger.debug("Standard Error:\n#{errstring}")
    
    if exit_code != 0
      $logger.error("(#{$$}): Execution failed #{cmd} with exit_code: #{exit_code.to_s}")
      if !retrying && exit_code == 140 && cmd.start_with?("/usr/bin/rhc-") # No nodes available...  ugh
        $logger.debug("Restarting mcollective and retrying")
        $logger.debug `service mcollective restart`
        sleep 5
        return run(cmd, outbuf, true)
      end
    end
    
    # append the buffers if an array container is provided
    if outbuf
      outbuf << outstring
      outbuf << errstring
    end

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
    $logger.debug("Command run: #{fullcmd}")
    $logger.debug("Standard Output:\n#{outstring}")
    $logger.debug("Standard Error:\n#{errstring}")
    $logger.debug("Exit Code: #{exit_code}")
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
  
  def rhc_update_namespace(app)
    old_namespace = app.namespace
    app.namespace = new_namespace = old_namespace + "new"
    old_hostname = app.hostname
    app.hostname = "#{app.name}-#{new_namespace}.#{$domain}"
    old_repo = app.repo
    app.repo = "#{$temp}/#{new_namespace}_#{app.name}_repo"
    FileUtils.mv old_repo, app.repo
    `sed -i "s,#{old_hostname},#{new_namespace},g" #{app.repo}/.git/config`
    old_file = app.file
    app.file = "#{$temp}/#{new_namespace}.json"
    FileUtils.mv old_file, app.file
    run("#{$create_domain_script} -n #{new_namespace} -l #{app.login} -p fakepw --alter -d").should == 0
    app.persist
  end

  def rhc_create_app(app)
    exit_code = run("#{$create_app_script} -l #{app.login} -a #{app.name} -r #{app.repo} -t #{app.type} -p fakepw -d")
    app.create_app_code = exit_code
    return app
  end

  def rhc_embed_add(app, type)
    result = run_stdout("#{$ctl_app_script} -l #{app.login} -a #{app.name} -p fakepw -e add-#{type} -d")
    if type.start_with?('mysql-')
      app.mysql_hostname = /^Connection URL: mysql:\/\/(.*)\/$/.match(result)[1]
      app.mysql_user = /^ +Root User: (.*)$/.match(result)[1]
      app.mysql_password = /^ +Root Password: (.*)$/.match(result)[1]
      app.mysql_database = /^ +Database Name: (.*)$/.match(result)[1]
  
      app.mysql_hostname.should_not be_nil
      app.mysql_user.should_not be_nil
      app.mysql_password.should_not be_nil
      app.mysql_database.should_not be_nil
    end

    app.embed = type
    app.persist
    return app
  end

  def rhc_embed_remove(app)
    puts app.name
    run("#{$ctl_app_script} -l #{app.login} -a #{app.name} -p fakepw -e remove-#{app.embed} -d").should == 0
    app.mysql_hostname = nil
    app.mysql_user = nil
    app.mysql_password = nil
    app.mysql_database = nil
    app.embed = nil
    app.persist
    return app
  end

  def rhc_ctl_stop(app)
    run("#{$ctl_app_script} -l #{app.login} -a #{app.name} -p fakepw -c stop -d").should == 0
    run("#{$ctl_app_script} -l #{app.login} -a #{app.name} -p fakepw -c status | grep '#{app.get_stop_string}'").should == 0
  end

  def rhc_add_alias(app)
    run("#{$ctl_app_script} -l #{app.login} -a #{app.name} -p fakepw -c add-alias --alias '#{app.name}-alias.example.com' -d").should == 0
  end
  
  def rhc_remove_alias(app)
    run("#{$ctl_app_script} -l #{app.login} -a #{app.name} -p fakepw -c remove-alias --alias '#{app.name}-alias.example.com' -d").should == 0
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
    run("#{$ctl_app_script} -l #{app.login} -a #{app.name} -p fakepw -c status | grep 'does not exist'").should == 0
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
    
    ps_pattern = /^\s*(\d+)\s+(\S+)$/
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
    }.compact

    found = proclist ? proclist.size : 0
    $logger.debug("Found = #{found} instances of #{cmd_name}")
    found
  end

  #
  # Count the number of processes owned by account that match the regex
  #
  def num_procs_like acct_name, regex
    command = "ps --no-headers -f -u #{acct_name}"
    $logger.debug("num_procs: executing #{command}")

    pid, stdin, stdout, stderr = Open4::popen4(command)

    stdin.close
    ignored, status = Process::waitpid2 pid
    exit_code = status.exitstatus

    outstrings = stdout.readlines
    errstrings = stderr.readlines
    $logger.debug("looking for #{regex}")
    $logger.debug("ps output:\n" + outstrings.join(""))

    proclist = outstrings.collect { |line|
      line.match(regex)
    }.compact!

    found = proclist ? proclist.size : 0
    $logger.debug("Found = #{found} instances of #{regex}")
    found
  end
end
World(CommandHelper)
