#!/usr/bin/env ruby
# Media and link validation tests

require "test/unit"
require 'rubygems'
require 'hpricot'
require 'open-uri'

class Validation < Test::Unit::TestCase
  
  @@base_url = 'https://localhost'
  @@base_path = '/app/'
  @@valid_responses = ['200', '302']
  @@ticket = 'test'
  
  @@blacklist = [
    '/wapps/sso/lostPassword.html'
  ]
  
  def test_all_links_are_valid
    @tested_pages = []
    invalid_links = get_invalid_links
    @tested_pages = []
    invalid_links.concat get_invalid_links('', true)
    puts "invalid links: #{invalid_links.inspect}"
    assert invalid_links.empty?
  end
  
  def get_invalid_links(url='', logged_in=false)
    # get fully qualified url if needed
    unless url.index 'http://' or url.index 'https://'
      unless url[0, 1] == '/'
        url = "#{@@base_url}#{@@base_path}#{url}"
      else
        url = "#{@@base_url}#{url}"
      end
    end
        
    # make sure this link is valid
    res_code = response_code(url)
    unless @@valid_responses.include? res_code
      return [url] #this is an invalid link
    end
    
    links = (get_elements :a, url, logged_in).collect do |a|
      a[:href]
    end
      
    invalid_links = []
    links.each do |link|
      if link_is_testable? link
        if link_is_local? link
          unless @tested_pages.include? link
            # recurse through openshift pages (once)
            @tested_pages.push link
            invalid_links.concat get_invalid_links(link)
          end
        else
          invalid_links << "page: #{url}; url: #{link}" unless @@valid_responses.include? response_code(link)
        end
      end
    end
    return invalid_links
  end
  
  def get_page_source(url, logged_in = false, redirect = true)
    opts = ''
    opts << " --cookie rh_sso=#{@ticket}" if logged_in 
    opts << ' -L' if redirect
    `curl -k#{opts} #{url}`
  end
  
  def get_elements(elem, url, logged_in = false)
    src = get_page_source url, logged_in
    doc = Hpricot(src)
    elems = []
    (doc/elem).each do |el|
      elems << el
    end
    return elems
  end
  
  # determine if a link points to another openshift page
  def link_is_local?(link)
    # test absolute links
    if link.index 'http://' or link.index 'https://'
      if link.index 'openshift.redhat.com' or link.index @@base_url
        true
      else
        false
      end
    else
      # relative link, assume true
      true
    end
  end
  
  # determine if a link should be tested
  def link_is_testable?(link)
    if link[0, 1] == '#' or link.index 'mailto:' or in_blacklist? link
      false
    else
      true
    end
  end
  
  def in_blacklist?(link)
    @@blacklist.each do |blacklisted|
      return true if link.index blacklisted
    end
    false
  end
  
  def response_code(url, logged_in=false, redirect=true)
    opts = ''
    opts << " --cookie rh_sso=#{@ticket}" if logged_in 
    opts << ' -L' if redirect 
    headers = `curl -Ik#{opts} #{url}`
    unless headers.nil? 
      last_header = headers.split("\r\n\r\n").last
      status = last_header.split("\r\n").first unless last_header.nil?
      status.split(' ')[1] unless status.nil?
    end
  end
  
end
