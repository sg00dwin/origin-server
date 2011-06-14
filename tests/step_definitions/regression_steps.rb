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

Then /^he can create a namespace and app$/ do
  @namespace = @info[:namespace]
  @repo_path="#{$temp}/#{@namespace}_#{@namespace}_repo"
  temp_text = run("#{$create_domain_script} -n #{@namespace} -l #{@rhc_login} -p fakepw -d")
  temp_text = run("#{$create_app_script} -a #{@namespace} -l #{@rhc_login} -r #{@repo_path} -t php-5.3 -p fakepw -d")
end

When /^he alters the namespace$/ do
  @tfile="#{$temp}/libralog"
  run("#{$create_domain_script} -n #{@namespace + "2"} -l #{@rhc_login} -p fakepw --alter > #{@tfile}")
end

Then /^the new namespace is enabled$/ do
  run("#{$user_info_script} -l #{@rhc_login} -p fakepw -i > #{@tfile}")
  check_file_has_string(@tfile, @namespace + "2").should be_true
  run("rm -f #{@tfile}")
end

#bug 699887
Then /^the host name can be obtained using php script$/ do
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
