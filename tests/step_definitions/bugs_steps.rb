require 'rubygems'
require 'net/http'
require 'uri'
require 'mechanize'
include Libra::Test::User
include Libra::Test::Util


#bug 693951
Given /^an end user$/ do
  namespaces = Array.new(1.to_i)
  @info = get_unique_username(namespaces)
  @rhc_login = @info[:login]
end

Then /^he could create a namespace$/ do
  @namespace = @info[:namespace]
  temp_text = run("#{$create_domain_script} -n #{@namespace} -l #{@rhc_login} -p fakepw -d")  
end

When /^he alter the namespace$/ do
  run("#{$create_domain_script} -n newnamespace -l #{@rhc_login} -p fakepw --alter > #{@tfile}")
end

Then /^the new namespace is enabled$/ do
  @tfile="#{$temp}/libralog"
  run("#{$user_info_script} -l #{@rhc_login} -p fakepw -i > #{@tfile}")
  check_file_has_string(@tfile, "newnamespace").should be_true
  run("rm -f #{@tfile}")
end


#bug 701159
Then /^come into an error when they are accessed$/ do
  @error_code = 0
  begin
    @urls.each do |url|
      @agent.get(url)
    end
  rescue Exception => e
    @error_code = 1
    $logger.error "Exception trying to access to url"
    $logger.error e.message
    $logger.error e.backtrace
  end
  @error_code.should == 1
end

#bug 700941
Then /^no READEME under misc and libs$/ do  
  File.exist?("#{@repo_path}/misc/README").should_not be_true
  File.exist?("#{@repo_path}/libs/README").should_not be_true
end

#bug 699887
Then /^can get host name using php script$/ do
  Dir.chdir(@repo_path)
  app_file = "php/index.php"    
  
  # Make a change to the app
  php_script = '<?php echo $_SERVER["HTTP_HOST"] ?>';
  run("sed -i 's/Welcome/#{php_script}/' #{app_file}")
  run("git commit -a -m 'Test to get host name'")
  run('git push')

  # Allow change to be loaded
  sleep 30

  # Mechanize agent
  agent = Mechanize.new { |agent|
    agent.user_agent_alias = 'Mac Safari'
    if ENV['http_proxy']
      print("(using proxy)")
      uri = URI.parse(ENV['http_proxy'])
      agent.set_proxy(uri.host, uri.port)
    end
  }
  host_name = "#{@app_php}-#{@namespace}.#{$domain}"
  page= agent.get("http://#{host_name}")
  page.body.index(host_name).should > -1

end
  

