require 'rubygems'
require 'rest_client'
require 'nokogiri'
require '/var/www/libra/broker/lib/express/broker/dns_service'


Before do
  @base_url = "https://localhost/broker/rest"
end

After do |scenario|
  dns_service = Express::Broker::DnsService.new({:end_point => "https://api2.dynect.net", :customer_name => "demo-redhat", 
  :user_name => "dev-rhcloud-user", :password => "vo8zaijoN7Aecoo", :domain_suffix => "dev.rhcloud.com", :zone => "rhcloud.com"})
  domains = ["cucumber", "app-cucumber"]
  i=0
  while i<3 
    domains.push("cucumber"+i.to_s)
    i += 1
  end
  domains.each do |domain|
    yes = dns_service.namespace_available?(domain)
    if !yes
      dns_service.deregister_namespace(domain)
    end
  end
  dns_service.publish
  dns_service.close
end
    
Given /^I am a valid user$/ do 
  
  @username = @account['accountname']
  @password = "xyz123"
  #TODO authenticate user

end

Given /^I send and accept "([^\"]*)"$/ do |type|
  @header = {:accept => type, :content_type => type}
end

Given /^I accept "([^\"]*)"$/ do |type|
  @accept_type = type
  @header = {:accept => type.to_s.downcase}
end

When /^I send a GET request to "([^\"]*)"$/ do |path|
  url = @base_url + path.to_s
  @request = RestClient::Request.new(:method => :get, :url => url, 
    :user => @username, :password => @password, :headers => @headers)
  begin
    @response = @request.execute()
  rescue => e
    @response = e.response
  end
end

When /^I send a POST request to "([^\"]*)" with the following:"([^\"]*)"$/ do |path, body|
  payload = {}
  params = body.split("&")
  params.each do |param|
    key, value = param.split("=", 2)
    payload[key] = value  
  end
  url = @base_url + path.to_s
  @request = RestClient::Request.new(:method => :post, :url => url, 
  :user => @username, :password => @password, :headers => @headers,
  :payload => payload)
  begin
    @response = @request.execute()
  rescue => e
    @response = e.response
  end
end

When /^I send a PUT request to "([^\"]*)" with the following:"([^\"]*)"$/ do |path, body|
  payload = {}
  params = body.split("&")
  params.each do |param|
    key, value = param.split("=", 2)
    payload[key] = value  
  end
  url = @base_url + path.to_s
  @request = RestClient::Request.new(:method => :put, :url => url, 
  :user => @username, :password => @password, :headers => @headers,
  :payload => payload)
  begin
    @response = @request.execute()
  rescue => e
    @response = e.response
  end
end

When /^I send a DELETE request to "([^\"]*)"$/ do |path|
   url = @base_url + path.to_s
  @request = RestClient::Request.new(:method => :delete, :url => url, 
    :user => @username, :password => @password, :headers => @headers)
  begin
    @response = @request.execute()
  rescue => e
    @response = e.response
  end
end

Then /^the response should be "([^\"]*)"$/ do |status|
  puts "#{@response.body}" if @response.code != status.to_i
  @response.code.should == status.to_i
end

Then /^the "([^\"]*)" response should be a "([^\"]*)" array with (\d+) "([^\"]*)" elements$/ do |type, tag, number_of_children, child_tag|
  if type.upcase == "XML"
    page = Nokogiri::XML(@response.body)
    page.xpath("//#{tag}/#{child_tag}").length.should == number_of_children.to_i
  elsif type.upcase == "JSON"
    page = JSON.parse(@response.body)
    page.map { |d| d[name] }.length.should == number_of_children.to_i
  else
    false
  end
end

Then /^the response descriptor should have "([^\"]*)" as dependencies$/ do |deps|
  if @accept_type.upcase == "XML"
    page = Nokogiri::XML(@response.body)
    desc_yaml = page.xpath("//response/data")
  elsif @accept_type.upcase == "JSON"
    page = JSON.parse(@response.body)
    desc_yaml = page["data"]
  end

  desc = YAML.load(desc_yaml.text.to_s)
  deps.split(",").each do |dep|
    desc["Requires"].should include(dep)
  end
end
