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

When /^check the number of the git files in libra dir$/ do
  @sfile = "#{$temp}/sfile"
  run("ls -d /var/lib/libra/*/git/*.git | wc -l > #{@sfile}")
  @git_files = File.open(@sfile,"r").readline
  @git_files = @git_files.to_i
  puts "first number: ",@git_files
end

And /^check the number of git repos by mc-facts$/ do
  sleep 15
  run("mc-facts git_repos > #{@sfile}")
  File.open(@sfile,"r").each_line do |line|
    if line.include?"found"
      @git_repos = line.split[0]
    end
  end
  @git_repos = @git_repos.to_i
  puts "second number: ",@git_repos
end

Then /^the first number is twice the second one$/ do
  @git_repos_org = @git_repos
  @git_files.should == @git_repos*2
end

And /^the second one adds (\d+)$/ do |number|
  @git_repos.should == @git_repos_org+number
end

When /^create two domains with same namespace$/ do
  namespaces = Array.new(1)
  info = get_unique_username(namespaces)
  namespace = info[:namespace]
  login = info[:login]
  exit_code = run("#{$create_domain_script} -n #{namespace} -l #{login} -p fakepw -d")
  exit_code.should == 0
  namespaces = Array.new(1)
  info = get_unique_username(namespaces)
  login = info[:login]
  @exit_code = run("#{$create_domain_script} -n #{namespace} -l #{login} -p fakepw -d")
end

Then /^this operation should fail$/ do
  @exit_code.should_not == 0
end

When /^the applications are stopped$/ do
  @data.each_pair do |url, value|
    namespace = "#{value[:namespace]}"
    login = "libra-test+#{namespace}@redhat.com"
    app = "#{value[:app]}"
    command = "#{$ctl_app_script} -l #{login} -a #{app} -c stop -p fakepw -d"
    puts command
    exit_code = run(command)
    exit_code.should == 0
  end
end

Then /^they should all be able to start$/ do
  @data.each_pair do |url, value|
    namespace = "#{value[:namespace]}"
    login = "libra-test+#{namespace}@redhat.com"
    app = "#{value[:app]}"
    command = "#{$ctl_app_script} -l #{login} -a #{app} -c start -p fakepw -d"
    puts command
    exit_code = run(command)
    exit_code.should == 0
  end
end

