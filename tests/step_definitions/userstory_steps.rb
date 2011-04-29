require 'rubygems'
require 'net/http'
require 'uri'
require 'mechanize'
include Libra::Test::User
include Libra::Test::Util


#US37 - TC21
When /^create a new php-5.3.2 app '(\w+)'$/ do |app_php|
  @namespaces = Array.new(1.to_i)
  info = get_unique_username(@namespaces)
  @namespace = info[:namespace]
  @login = info[:login]
  @app_php = app_php
  framework="php-5.3.2"
  @repo_path="#{$temp}/#{@namespace}_#{@app_php}_repo"

  begin
    run("#{$create_domain_script} -n #{@namespace} -l #{@login} -p fakepw -d")
    run("#{$create_app_script} -l #{@login} -a #{@app_php} -r #{@repo_path} -t #{framework} -p fakepw -d")
  rescue Exception => e
    $logger.error "Exception trying to create app #{@app_php}"
    $logger.error e.message
    $logger.error e.backtrace
  end
end

Then /^the PHP app can be accessible$/ do
  host = "#{@app_php}-#{@namespace}.#{$domain}"
  begin
    $logger.info("Checking host #{host}")
    res = Net::HTTP.start(host, 30) do |http|
      http.read_timeout = 30
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
end

When /^destroy this PHP app using rhc-ctl-app$/ do
  run("#{$ctl_app_script} -a #{@app_php} -l #{@login} -p fakepw -c destroy -d")
end

Then /^the PHP app should not be accessible$/ do
  host = "#{@app_php}-#{@namespace}.#{$domain}"
  begin
    $logger.info("Checking host #{host}")
    res = Net::HTTP.start(host, 30) do |http|
      http.read_timeout = 30
      http.get("/health_check.php")
    end
    code = res.code
  rescue Exception => e
    $logger.error "Exception trying to access #{host}"
    $logger.error "Response code = #{code}"
    $logger.error e.message
    $logger.error e.backtrace
    code = -1
    #remove local repo
    run("rm -rf #{@repo_path}")
  end
  File.exist?(@repo_path).should_not be_true
end


#US37 - TC29
Then /^new app created under the generated git repo path$/ do
  @health_check_file = "#{@repo_path}/php/index.php"
  File.exists?(@health_check_file).should be_true
end

When /^create app with -n option$/ do
  namespaces = Array.new(1.to_i)
  info = get_unique_username(namespaces)
  namespace = info[:namespace]
  login = info[:login]
  @app_php = "phpapp"
  framework="php-5.3.2"
  begin
    run("#{$create_domain_script} -n #{namespace} -l #{login} -p fakepw -d")
    run("#{$create_app_script} -l #{login} -a #{@app_php} -n -t #{framework} -p fakepw -d")
  rescue Exception => e
    $logger.error "Exception trying to create app #{@app_php} with -n option"
    $logger.error e.message
    $logger.error e.backtrace
  end
end
Then /^only create remote space and do not pull it locally$/ do
  File.exist?(@app_php).should_not be_true
end


#US37 - TC3
When /^check the status of this app using rhc-ctl-app$/ do
  @sfile = "#{$temp}/#{@app_php}"
  run("#{$ctl_app_script} -a #{@app_php} -l #{@login} -p fakepw -c status -d > #{@sfile}")
end
Then /^Exit Code is 0$/ do
  @sfile = "#{$temp}/#{@app_php}"
  File.open(@sfile).gets.index("Exit Code: 0").should_not == -1
  run("rm -rf #{@sfile}")
end

When /^stop this PHP app$/ do
  begin
    run("#{$ctl_app_script} -a #{@app_php} -l #{@login} -p fakepw -c stop -d")
  rescue Exception => e
    $logger.error "Exception trying to stop #{@app_php}"
    $logger.error e.message
    $logger.error e.backtrace
  end
end

Then /^Exit Code is not 0$/ do
  @sfile = "#{$temp}/#{@app_php}"
  File.open(@sfile).gets.index("Exit Code: 0").should == nil
  #clean running log
  run("rm -rf #{@sfile}")
end

When /^start this PHP app$/ do
  begin
    run("#{$ctl_app_script} -a #{@app_php} -l #{@login} -p fakepw -c start -d")
  rescue Exception => e
    $logger.error "Exception trying to stop #{@app_php}"
    $logger.error e.message
    $logger.error e.backtrace
  end
end

When /^restart this PHP app$/ do
  begin
    run("#{$ctl_app_script} -a #{@app_php} -l #{@login} -p fakepw -c restart -d")
  rescue Exception => e
    $logger.error "Exception trying to restart #{@app_php}"
    $logger.error e.message
    $logger.error e.backtrace
  end
end

When /^reload this PHP app$/ do
  begin
    run("#{$ctl_app_script} -a #{@app_php} -l #{@login} -p fakepw -c reload -d")
  rescue Exception => e
    $logger.error "Exception trying to reload #{@app_php}"
    $logger.error e.message
    $logger.error e.backtrace
  end
end


And /^create a domain$/ do
  @namespaces = Array.new(1.to_i)
  info = get_unique_username(@namespaces)
  @namespace = info[:namespace]
  @login = info[:login]
  @create_error_network_off = 0
  begin
    run("#{$create_domain_script} -n #{@namespace} -l #{@login} -p fakepw -d")
  rescue Exception => e
    @create_error_network_off = 1
    $logger.error "Exception trying to create domain #{@namespace}"
    $logger.error e.message
    $logger.error e.backtrace
  end
end


#US362-TC115
When /^create an app without -a$/ do
  @app_name = "app"
  framework="rack-1.1.0"
  @repo_path="#{$temp}/#{@namespace}_#{@app_name}_repo"
  @create_error_lack_param = 0
  @sfile = "#{$temp}/#{@app_name}_1"
  begin
    run("#{$create_app_script} -l #{@login} -r #{@repo_path} -t #{framework} -p fakepw -d > #{@sfile}")
  rescue Exception => e
    @create_error_lack_param = 1
    $logger.error "Exception trying to create app #{@app_name}"
    $logger.error e.message
    $logger.error e.backtrace
    run("cat '#{e.message}' > #{@sfile}")
  end
end

Then /^throw out an error application is required$/ do
  File.open(@sfile).gets.index("application is required").should_not == -1
  #clean running log
  run("rm -f #{@sfile}")
end

When /^create an app without -t$/ do
  @app_name = "app"
  framework="rack-1.1.0"
  @repo_path="#{$temp}/#{@namespace}_#{@app_name}_repo"
  @create_error_lack_param = 0
  @sfile = "#{$temp}/#{@app_name}_2"
  begin
    run("#{$create_app_script} -l #{@login} -a #{@app_name} -r #{@repo_path} -p fakepw -d > #{@sfile}")
  rescue Exception => e
    @create_error_lack_param = 1
    $logger.error "Exception trying to create app #{@app_name}"
    $logger.error e.message
    $logger.error e.backtrace
    cat e.message > @sfile
  end
end
Then /^throw out an error Type is required$/ do
  File.open(@sfile).gets.index("Type is required").should_not == -1
  #clean running log
  run("rm -f #{@sfile}")
end

When /^create a new rack-1.1.0 app '(\w+)'$/ do |app_rack|
  @app_rack = app_rack
  framework="rack-1.1.0"
  @repo_path="#{$temp}/#{@namespace}_#{@app_rack}_repo"
  begin
    run("#{$create_domain_script} -n #{@namespace} -l #{@login} -p fakepw -d")
    run("#{$create_app_script} -l #{@login} -a #{@app_rack} -r #{@repo_path} -t #{framework} -p fakepw -d")
  rescue Exception => e
    $logger.error "Exception trying to create app #{@app_rack}"
    $logger.error e.message
    $logger.error e.backtrace
  end
end

And /^using rhc-ctl-app without -c$/ do
  @sfile = "#{$temp}/#{@app_rack}_1"
  @create_error_lack_param = 0
  begin
    run("#{$ctl_app_script} -a #{@app_rack} -l #{@login} -p fakepw -d > #{@sfile}")
  rescue Exception => e
    @create_error_lack_param = 1
    $logger.error "Exception trying to rhc-ctl-app #{@app_rack}"
    $logger.error e.message
    $logger.error e.backtrace
    cat e.message > @sfile
  end
end
Then /^throw out an error Command is required$/ do
  File.open(@sfile).gets.index("Command is required").should_not == -1
  #clean running log
  run("rm -f #{@sfile}")
end
When /^using rhc-ctl-app without -a$/ do
  @sfile = "#{$temp}/#{@app_rack}_2"
  @create_error_lack_param = 0
  begin
    run("#{$ctl_app_script} -l #{@login} -p fakepw -c status -d > #{@sfile}")
  rescue Exception => e
    @create_error_lack_param = 1
    $logger.error "Exception trying to rhc-ctl-app #{@app_rack}"
    $logger.error e.message
    $logger.error e.backtrace
    cat e.message > @sfile
  end
end

#US59 - TC18, TC52, TC54, TC55, TC56
When /^check SELinux status$/ do
  @tfile="#{$temp}/libralog"
  run("sestatus > #{@tfile}")
end
Then /^SELinux is running in enforcing mode$/ do
  File.open(@tfile).gets.index("enforcing").should_not == -1
  run("rm -f #{@tfile}")
end
When /^check whether SELinux module for Libra is installed$/ do
  run("semodule -l | grep libra > #{@tfile}")
end
Then /^Selinux for Libra is installed$/ do
  File.open(@tfile).gets.index("libra").should_not == -1
  run("rm -f #{@tfile}")
end
When /^check whether SELinux audit service is running on the node$/ do
  run("service auditd status > #{@tfile}")
end
Then /^SELinux audit service is running$/ do
  File.open(@tfile).gets.index("is running").should_not == -1
  run("rm -f #{@tfile}")
end
When /^clean old audit.log$/ do
  @audit_file = "/var/log/audit/audit.log"
  run("rm -f #{@audit_file}")
end
And /^create an rack-1.1.0 app$/ do
  @namespaces = Array.new(1.to_i)
  info = get_unique_username(@namespaces)
  @namespace = info[:namespace]
  @login = info[:login]
  @app_rails = "railsapplication"
  framework="rack-1.1.0"
  @repo_path="#{$temp}/#{@namespace}_#{@app_rails}_repo"
  begin
    run("#{$create_domain_script} -n #{@namespace} -l #{@login} -p fakepw -d")
    run("#{$create_app_script} -l #{@login} -a #{@app_rails} -r #{@repo_path} -t #{framework} -p fakepw -d")
  rescue Exception => e
    $logger.error "Exception trying to create #{@app_rails}"
    $logger.error e.message
    $logger.error e.backtrace
  end
end
And /^check audit.log for AVC denials$/ do
  run("ausearch -m avc > #{@tfile}")
end
Then /^no AVC denials$/ do
  File.open(@tfile).gets.should == nil
  run("rm -f #{@tfile}")
end

When /^stop the rack-1.1.0 app$/ do
  begin
    run("#{$ctl_app_script} -a #{@app_rails} -l #{@login} -p fakepw -c stop -d")
  rescue Exception => e
    $logger.error "Exception trying to stop #{@app_rails}"
    $logger.error e.message
    $logger.error e.backtrace
  end
end

When /^start the rack-1.1.0 app$/ do
  begin
    run("#{$ctl_app_script} -a #{@app_rails} -l #{@login} -p fakepw -c start -d")
  rescue Exception => e
    $logger.error "Exception trying to start #{@app_rails}"
    $logger.error e.message
    $logger.error e.backtrace
  end
end

When /^restart the rack-1.1.0 app$/ do
  begin
    run("#{$ctl_app_script} -a #{@app_rails} -l #{@login} -p fakepw -c restart -d")
  rescue Exception => e
    $logger.error "Exception trying to restart #{@app_rails}"
    $logger.error e.message
    $logger.error e.backtrace
  end
end

When /^reload the rack-1.1.0 app$/ do
  begin
    run("#{$ctl_app_script} -a #{@app_rails} -l #{@login} -p fakepw -c reload -d")
  rescue Exception => e
    $logger.error "Exception trying to reload #{@app_rails}"
    $logger.error e.message
    $logger.error e.backtrace
  end
end

When /^destroy the rack-1.1.0 app$/ do
  begin
    run("#{$ctl_app_script} -a #{@app_rails} -l #{@login} -p fakepw -c destroy -d")
  rescue Exception => e
    $logger.error "Exception trying to destroy #{@app_rails}"
    $logger.error e.message
    $logger.error e.backtrace
  end
end







