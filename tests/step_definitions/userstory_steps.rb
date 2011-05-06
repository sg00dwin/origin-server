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

Then /^this PHP app is running$/ do
  check_file_has_string(@sfile,"Total Accesses:").should == true
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

Then /^this PHP app is stopped$/ do
  check_file_has_string(@sfile,"Application '#{@app_php}' is either stopped or inaccessible").should == true
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
  @sfile = "#{$temp}/#{@app_php}"
  begin
    run("#{$ctl_app_script} -a #{@app_php} -l #{@login} -p fakepw -c restart -d > #{@sfile}")
  rescue Exception => e
    $logger.error "Exception trying to restart #{@app_php}"
    $logger.error e.message
    $logger.error e.backtrace
  end
end

Then /^this PHP app is restarted$/ do
    check_file_has_string(@sfile,"Success").should == true
    #clean running log
    run("rm -rf #{@sfile}")
end

When /^reload this PHP app$/ do
  @sfile = "#{$temp}/#{@app_php}"
  begin
    run("#{$ctl_app_script} -a #{@app_php} -l #{@login} -p fakepw -c reload -d > #{@sfile}")
  rescue Exception => e
    $logger.error "Exception trying to restart #{@app_php}"
    $logger.error e.message
    $logger.error e.backtrace
  end
end

Then /^this PHP app is reloaded/ do
    check_file_has_string(@sfile,"Success").should == true
    #clean running log
    run("rm -rf #{@sfile}")
end


#US362-TC115
And /^create a domain$/ do
  @namespaces = Array.new(1.to_i)
  info = get_unique_username(@namespaces)
  @namespace = info[:namespace]
  @login = info[:login]
  begin
    run("#{$create_domain_script} -n #{@namespace} -l #{@login} -p fakepw -d")
  rescue Exception => e
    $logger.error "Exception trying to create domain #{@namespace}"
    $logger.error e.message
    $logger.error e.backtrace
  end
end

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
  check_file_has_string(@sfile,"application is required").should == true
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
  check_file_has_string(@sfile,"Type is required").should == true
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
  begin
    run("#{$ctl_app_script} -a #{@app_rack} -l #{@login} -p fakepw -d > #{@sfile}")
  rescue Exception => e
    $logger.error "Exception trying to rhc-ctl-app #{@app_rack}"
    $logger.error e.message
    $logger.error e.backtrace
    cat e.message > @sfile
  end
end
Then /^throw out an error Command is required$/ do
  check_file_has_string(@sfile,"Command is required").should == true
  #clean running log
  run("rm -f #{@sfile}")
end
When /^using rhc-ctl-app without -a$/ do
  @sfile = "#{$temp}/#{@app_rack}_2"
  begin
    run("#{$ctl_app_script} -l #{@login} -p fakepw -c status -d > #{@sfile}")
  rescue Exception => e
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
  check_file_has_string(@tfile,"enforcing").should == true
  run("rm -f #{@tfile}")
end
When /^check whether SELinux module for Libra is installed$/ do
  run("semodule -l | grep libra > #{@tfile}")
end
Then /^Selinux for Libra is installed$/ do
  check_file_has_string(@tfile,"libra").should == true
  run("rm -f #{@tfile}")
end
When /^check whether SELinux audit service is running on the node$/ do
  run("service auditd status > #{@tfile}")
end
And /^start SELinux audit service if it is stopped$/ do
  if !check_file_has_string(@tfile,"is running")
    run("service auditd start")
    run("rm -f #{@tfile}")
    run("service auditd status > #{@tfile}")
  end
end
Then /^SELinux audit service is running$/ do
  check_file_has_string(@tfile,"is running").should == true
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


#US280 - TC19
Given /^a Mechanize agent and a registered user$/ do
  run("export http_proxy='file.rdu.redhat.com:3128'")
  @agent = Mechanize.new { |agent|
    agent.user_agent_alias = 'Mac Safari'
    if ENV['http_proxy']
      print("(using proxy)")
      uri = URI.parse(ENV['http_proxy'])
      agent.set_proxy(uri.host, uri.port)
    end
  }
  @namespaces = Array.new(1.to_i)
  info = get_unique_username(@namespaces)
  @rh_login = info[:login]
end

Then /^can access our cloud website$/ do
#  page= @agent.get('https://stg.openshift.redhat.com/app/login/')
  page= @agent.get('https://localhost/app/login/')
  page.body.index("Already Have a Login").should_not == -1  
end

Then /^can login our cloud website$/ do
  page= @agent.get('https://localhost/app/login/')
  login_result = page.form_with(:action => '/app/login') do |log_in|
       log_in.login = @rh_login
       log_in.password = "fakepw"
  end.submit
  login_html = ""
  login_result.links.each do |link|
      text = link.text.strip
      next unless text.length > 0
      login_html << text
  end
  login_html.index("Logout").should > 0  
end


#US414
Given /^the libra controller configuration$/ do
  @c_file = "/etc/libra/controller.conf"
  File.exists?(@c_file).should be_true
end
Then /^the number of apps per user is 1$/ do  
  check_file_has_string("/etc/libra/controller.conf", "per_user_app_limit=1").should == true
end



#US27
Then /^would fail to create the second '(\w+)' application for 'php\-(\d+)\.(\d+)\.(\d+)'$/ do |app, arg1, arg2, arg3|  
  framework = 'php-'+arg1+'.'+arg2+'.'+arg3
  repo_path="#{$temp}/#{@namespace}_#{app}_repo"
  begin
    tfile="#{$temp}/libralog"
    run("#{$create_app_script} -l #{@login} -a #{app} -r #{repo_path} -t #{framework} -p fakepw > #{tfile}")
    check_file_has_string(tfile,"has already reached the application limit of 1").should == true
    run("rm -f #{tfile}")
  rescue Exception=>e
    #handle e
    $logger.error "Exception:" +e.message
  end  
end

#US84 - TC39
Given /^a user$/ do
  namespaces = Array.new(1.to_i)
  @info = get_unique_username(namespaces)
  @rhc_login = @info[:login]  
end
Then /^could create a namespace$/ do
  @namespace = @info[:namespace]
  run("#{$create_domain_script} -n #{@namespace} -l #{@rhc_login} -p fakepw -d")
end

When /^alter the namespace$/ do
  @tfile="#{$temp}/libralog"
  run("#{$create_domain_script} -n newnamespace -l #{@rhc_login} -p fakepw --alter > #{@tfile}")
end

Then /^clould not alter the namespace$/ do
  check_file_has_string(@tfile, "You may not change your registered namespace of: #{@namespace}").should == true
  run("rm -f #{@tfile}")
end




private
#check if a given file contains a given string
def check_file_has_string(file_name,string)
  all_content = ""
  if !File.exist?(file_name)
    return false
  end
  File.open(file_name) do |file|
      file.each_line do |line|
        all_content << line
     end
  end
  if !all_content.nil? && !all_content.index(string).nil? && all_content.index(string) > -1
    return true
  end
  return false
end


def print_file(file_name)
    File.open(file_name) do |file|
      file.each_line do |line|
        $logger.info line
      end
    end
end





