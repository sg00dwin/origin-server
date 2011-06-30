require 'rubygems'
require 'net/http'
require 'uri'
require 'mechanize'
include Libra::Test::User
include Libra::Test::Util


#US37 - TC21
When /^a new php-5.3 app '(\w+)' is created$/ do |app_php|
  @namespaces = Array.new(1.to_i)
  info = get_unique_username(@namespaces)
  @namespace = info[:namespace]
  @login = info[:login]
  @app_php = app_php
  framework="php-5.3"
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

Then /^the PHP app is accessible$/ do
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

When /^the PHP app is destroyed using rhc-ctl-app$/ do
  run("#{$ctl_app_script} -a #{@app_php} -l #{@login} -p fakepw -c destroy -d -b")
end

Then /^the PHP app is not accessible$/ do
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
Then /^the new app is created under the generated git repo path$/ do
  @health_check_file = "#{@repo_path}/php/index.php"
  File.exists?(@health_check_file).should be_true
end

When /^an app is created with -n option$/ do
  namespaces = Array.new(1.to_i)
  info = get_unique_username(namespaces)
  namespace = info[:namespace]
  login = info[:login]
  @app_php = "phpapp"
  framework="php-5.3"
  begin
    run("#{$create_domain_script} -n #{namespace} -l #{login} -p fakepw -d")
    run("#{$create_app_script} -l #{login} -a #{@app_php} -n -t #{framework} -p fakepw -d")
  rescue Exception => e
    $logger.error "Exception trying to create app #{@app_php} with -n option"
    $logger.error e.message
    $logger.error e.backtrace
  end
end
Then /^only the remote space is created and it is not pulled in locally$/ do
  File.exist?(@app_php).should_not be_true
end


#US37 - TC3
When /^the status of this app is checked using rhc-ctl-app$/ do
  @sfile = "#{$temp}/#{@app_php}"
  run("#{$ctl_app_script} -a #{@app_php} -l #{@login} -p fakepw -c status -d > #{@sfile}")
end

Then /^this PHP app is running$/ do
  check_file_has_string(@sfile,"Total Accesses:").should == true
  run("rm -rf #{@sfile}")
end

When /^I stop this PHP app$/ do
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


When /^I start this PHP app$/ do
  begin
    run("#{$ctl_app_script} -a #{@app_php} -l #{@login} -p fakepw -c start -d")
  rescue Exception => e
    $logger.error "Exception trying to stop #{@app_php}"
    $logger.error e.message
    $logger.error e.backtrace
  end
end


When /^I restart this PHP app$/ do
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

When /^I reload this PHP app$/ do
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
And /^a created domain$/ do
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

When /^an app is created without -a$/ do
  @app_name = "app"
  framework="rack-1.1"
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

Then /^display an error that the application is required$/ do
  check_file_has_string(@sfile,"application is required").should == true
  #clean running log
  run("rm -f #{@sfile}")
end

When /^an app is created without -t$/ do
  @app_name = "app"
  framework="rack-1.1"
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
Then /^display an error that the type is required$/ do
  check_file_has_string(@sfile,"Type is required").should == true
  #clean running log
  run("rm -f #{@sfile}")
end

When /^a new rack-1.1 app '(\w+)' is created$/ do |app_rack|
  @app_rack = app_rack
  framework="rack-1.1"
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

And /^rhc-ctl-app is run without -c$/ do
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
Then /^display an error that the command is required$/ do
  check_file_has_string(@sfile,"Command or embed is required").should == true
  #clean running log
  run("rm -f #{@sfile}")
end
When /^rhc-ctl-app is run without -a$/ do
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
When /^SELinux status is checked$/ do
  @tfile="#{$temp}/libralog"
  run("sestatus > #{@tfile}")
end
Then /^SELinux is running in enforcing mode$/ do
  check_file_has_string(@tfile,"enforcing").should == true
  run("rm -f #{@tfile}")
end
When /^SELinux module for Libra is checked to see if it is installed$/ do
  run("semodule -l | grep libra > #{@tfile}")
end
Then /^SELinux for Libra is installed$/ do
  check_file_has_string(@tfile,"libra").should == true
  run("rm -f #{@tfile}")
end
When /^SELinux audit service is checked to see if it is running on the node$/ do
  run("service auditd status > #{@tfile}")
end
And /^SELinux audit service is started if it is stopped$/ do
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
When /^old audit.log is cleaned$/ do
  @audit_file = "/var/log/audit/audit.log"
  run("rm -f #{@audit_file}")
end
And /^a rack-1.1 app is created$/ do
  @namespaces = Array.new(1.to_i)
  info = get_unique_username(@namespaces)
  @namespace = info[:namespace]
  @login = info[:login]
  @app_rails = "railsapplication"
  framework="rack-1.1"
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
And /^audit.log is checked for AVC denials$/ do
  run("ausearch -m avc > #{@tfile}")
end
Then /^there are no AVC denials$/ do
  File.open(@tfile).gets.should == nil
  run("rm -f #{@tfile}")
end

When /^the rack-1.1 app is stopped$/ do
  begin
    run("#{$ctl_app_script} -a #{@app_rails} -l #{@login} -p fakepw -c stop -d")
  rescue Exception => e
    $logger.error "Exception trying to stop #{@app_rails}"
    $logger.error e.message
    $logger.error e.backtrace
  end
end

When /^the rack-1.1 app is started$/ do
  begin
    run("#{$ctl_app_script} -a #{@app_rails} -l #{@login} -p fakepw -c start -d")
  rescue Exception => e
    $logger.error "Exception trying to start #{@app_rails}"
    $logger.error e.message
    $logger.error e.backtrace
  end
end

When /^the rack-1.1 app is restarted$/ do
  begin
    run("#{$ctl_app_script} -a #{@app_rails} -l #{@login} -p fakepw -c restart -d")
  rescue Exception => e
    $logger.error "Exception trying to restart #{@app_rails}"
    $logger.error e.message
    $logger.error e.backtrace
  end
end

When /^the rack-1.1 app is reloaded$/ do
  begin
    run("#{$ctl_app_script} -a #{@app_rails} -l #{@login} -p fakepw -c reload -d")
  rescue Exception => e
    $logger.error "Exception trying to reload #{@app_rails}"
    $logger.error e.message
    $logger.error e.backtrace
  end
end

When /^the rack-1.1 app is destroyed$/ do
  begin
    run("#{$ctl_app_script} -a #{@app_rails} -l #{@login} -p fakepw -c destroy -d -b")
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

Then /^the user can access our cloud website$/ do
#  page= @agent.get('https://stg.openshift.redhat.com/app/login/')
  page= @agent.get('https://localhost/app/login/')
  page.body.index("Already Have a Login").should_not == -1  
end

Then /^the user can log in to our cloud website$/ do
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
  check_file_has_string("/etc/libra/controller.conf", "per_user_app_limit=5").should == true
end



#US27
Then /^a second '(\w+)' application for 'php\-(\d+)\.(\d+)' fails to be created$/ do |app, arg1, arg2|  
  framework = 'php-'+arg1+'.'+arg2
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


#US346
Then /^users can create a new rails app using rails new$/ do
   # Hit the health check page for each app
   @data.each_pair do |url, value|
    repo = "#{$temp}/#{value[:namespace]}_#{value[:app]}_repo"
    $logger.info("Changing to dir=#{repo}")
    Dir.chdir(repo)

    app_file = "public/index.html"
    app_name = value[:app]
    
    #Create new rails app
    run("rails new #{app_name}")
    Dir.chdir(repo+"/#{app_name}")
    run("sed -i 's/Welcome/TEST/' #{app_file}")
    run("bundle install")
    Dir.chdir(repo)
    run("cp -r #{app_name}/* .")

    run("rm -rf #{app_name}/")

    #commit 
    run("git add .")
    run("git commit -m 'Add rails app'")
    run("git push")
 
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
  # Format = code - url
  $logger.info("Rails App Results")
  results = []
  @data.each_pair do |url, value|
    $logger.info("#{value[:change_code]} - #{url} (#{value[:type]})")
    results << value[:change_code]
  end
  # Get all the unique responses
  # There should only be 1 result [0]
  uniq_responses = results.uniq
  uniq_responses.length.should == 1
  uniq_responses[0].should == 0

end

Then /^they are accessible within (\d+) seconds$/ do |timeout|
  @data.each_pair do |url, value|
    connect(url, "/config.ru", timeout.to_i) do |code, time, body|
      value[:code] = code
      value[:time] = time
    end unless value[:failed]
  end

  $logger.info("Accessibility Results")
  results = []
  @data.each_pair do |url, value|
    $logger.info("#{value[:code]} / #{value[:time]} - #{url} (#{value[:type]})")
    results << value[:code]
  end
  uniq_responses = results.uniq
  uniq_responses.length.should == 1
  uniq_responses[0].should == 0
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





