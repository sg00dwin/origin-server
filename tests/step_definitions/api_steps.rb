require 'rubygems'
require 'rest_client'
require 'nokogiri'
require '/var/www/libra/broker/lib/express/broker/dns_service'
require 'logger'

@random = nil
Before do
  @base_url = "https://localhost/broker/rest"
end

After do |scenario|
  dns_service = Express::Broker::DnsService.new({:end_point => "https://api2.dynect.net", :customer_name => "demo-redhat",
    :user_name => "dev-rhcloud-user", :password => "vo8zaijoN7Aecoo", :domain_suffix => "dev.rhcloud.com", :zone => "rhcloud.com", :log_file => "/dev/null"})

  domains = ["cucumber#{@random}", "cucumber1#{@random}", "app-cucumber#{@random}"]
  domains.each do |domain|
    yes = dns_service.namespace_available?(domain)
    if !yes
    #puts "deregistering #{domain}"
    dns_service.deregister_namespace(domain)
    end
  end
  dns_service.publish
  dns_service.close
  @random = nil
end

Given /^I am a valid user$/ do

  @username = @account['accountname']
  @password = "xyz123"
#TODO authenticate user

end

Given /^I send and accept "([^\"]*)"$/ do |type|
  @headers = {:accept => type, :content_type => type}
end

Given /^I accept "([^\"]*)"$/ do |type|
  @accept_type = type
  @headers = {:accept => type.to_s.downcase}
end

When /^I send a GET request to "([^\"]*)"$/ do |path|
  path = sub_random(path)
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
  path = sub_random(path)
  body = sub_random(body)
  #puts "path #{path}"
  #puts "body #{body}"
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
  path = sub_random(path)
  body = sub_random(body)
  #puts "path #{path}"
  #puts "body #{body}"
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
  path = sub_random(path)
  #puts "path #{path}"

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
  puts "#{@response.body}"  if @response.code != status.to_i
  @response.code.should == status.to_i
end

Then /^the response should be a "([^\"]*)" with attributes "([^\"]*)"$/ do |tag, attributes_str|
  attributes_str = sub_random(attributes_str)
  attributes_array = attributes_str.split("&")
  if @accept_type.upcase == "XML"
    #puts @response.body
    result = Nokogiri::XML(@response.body)
    attributes_array.each do |attributes|
      key, value = attributes.split("=", 2)
      #puts "#{result.xpath("//#{tag}/#{key}").text} #{value}"
      result.xpath("//#{tag}/#{key}").text.should == value
    end
  elsif @accept_type.upcase == "JSON"
    result = JSON.parse(@response.body)
    obj = result["data"]
    attributes_array.each do |attributes|
      key, value = attributes.split("=", 2)
      obj[key].should == value
    end
  else
  false
  end
end

Then /^the response should be a list of "([^\"]*)" with attributes "([^\"]*)"$/ do |tag, attributes_str|
  attributes_str = sub_random(attributes_str)
  attributes_array = attributes_str.split("&")
  if @accept_type.upcase == "XML"
    #puts @response.body
    result = Nokogiri::XML(@response.body)
    attributes_array.each do |attributes|
      key, value = attributes.split("=", 2)
      #puts "#{result.xpath("//#{tag}/#{key}").text} #{value}"
      result.xpath("//#{tag}/#{key}").text.should == value
    end
  elsif @accept_type.upcase == "JSON"
    result = JSON.parse(@response.body)
    obj = result["data"]
    attributes_array.each do |attributes|
      key, value = attributes.split("=", 2)
      obj[key].should == value
    end
  else
  false
  end
end

Then /^the error message should have "([^\"]*)"$/ do |attributes_str|
  attributes_str = sub_random(attributes_str)
  attributes_array = attributes_str.split("&")
  if @accept_type.upcase == "XML"
    #puts @response.body
    result = Nokogiri::XML(@response.body)
    messages = result.xpath("//message")
    attributes_array.each do |attributes|
      key, value = attributes.split("=", 2)
      key = key.sub("_", "-")
      messages.each do |message|
        result.xpath("/#{key}").text.should == value
      end
    end
  elsif @accept_type.upcase == "JSON"
    result = JSON.parse(@response.body)
    messages = result["messages"]
    attributes_array.each do |attributes|
      key, value = attributes.split("=", 2)
      messages.each do |message|
        message[key].to_s.should == value
      end
    end
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

def sub_random(value)
  if value and value.include? "<random>"
    @random = rand(1000) unless @random
    value = value.sub("<random>", @random.to_s)
  end
  return value
end
