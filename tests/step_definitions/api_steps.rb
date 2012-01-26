require 'rubygems'
require 'rest_client'
require 'nokogiri'

Before do
  @base_url = "https://localhost/broker/rest"
end

After do |scenario|
  #TODO delete user
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


