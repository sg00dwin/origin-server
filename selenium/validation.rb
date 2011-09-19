#!/usr/bin/env ruby
# Media and link validation tests

require "test/unit"
require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'logger'
require 'net/http'
require 'net/https'
require 'uri'
require 'yaml'

class Validation < Test::Unit::TestCase
  
  @@base_url = 'https://localhost'
  @@base_path = '/app/'
  @@ticket = 'test'
  @@retry_limit = 3
  @@local_hosts = [
    'localhost',
    'openshift.redhat.com'
  ]
  
  @@blacklist = [
    '/wapps/sso/lostPassword.html'
  ]

  $logger ||= Logger.new(STDERR)
  $logger.level = Logger::INFO

  def setup
    puts "Making sure links are empty"
    @@invalid_links = []
    @@tested_pages = []
  end
  
  def test_logged_in_links_are_valid
    results = check_page('', true)
    check_results
  end

  def test_all_public_links_are_valid
    results = check_page('')
    check_results
  end

  def check_results
    $logger.info "Checked pages: #{YAML.dump @@tested_pages.sort}"
    assert @@invalid_links.empty?, YAML.dump(@@invalid_links.sort)
  end

  def check_page(url, logged_in = false)
    uri = build_uri(url)
    # Make sure we don't retest pages
    if @@tested_pages.include? uri.to_s
      $logger.debug "Skipping #{uri.to_s}"
      return
    end
    @@tested_pages << uri.to_s

    # Make sure we're working with a valid URI
    $logger.debug "Testing URI: #{uri.to_s}"

    if link_is_testable? uri
      # Only HEAD remote sites to save time
      method = @@local_hosts.include?( uri.host ) ? :get : :head

      # Make sure the page is valid
      response = fetch(uri,{:logged_in => logged_in,:method => method})
      case response
      when Net::HTTPSuccess, Net::HTTPRedirection
        if response.body
          links = get_links(response.body)
          links.each{|link| check_page(link,logged_in)}
        end
      else
        @@invalid_links << url
      end
    end
  end

  def build_uri(url)
    $logger.debug("Building URI: #{url}")

    uri = URI.parse(url)
    if [URI::Generic].include? uri.class
      # Some sort of relative URI
      unless url.start_with?('/app')
        url = @@base_path + url
      end
      uri = URI.join(@@base_url,url)
    end
    uri
  end

  def fetch(uri, args)
    args = {
      :logged_in => false, 
      :redirect => true, 
      :limit => 10,
      :method => :get,
      :retries => 0
    }.merge(args)

    args[:limit]-=1

    # You should choose better exception.
    raise ArgumentError, 'HTTP redirect too deep' if args[:limit] == 0

    $logger.debug "#{args[:method].to_s.upcase} #{"(retry #{args[:retries]})" if args[:retries] > 0} #{uri.to_s}"
    headers = {
      'Cookie' => "rh_sso=#{@ticket}"
    }

    opts = {}

    http = Net::HTTP.new( uri.host, uri.port )
    http.open_timeout = 10
    http.read_timeout = 10
    if uri.scheme == 'https'
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    response = http.start{|http|
      begin
        response = http.__send__(
          args[:method],
          (uri.path == '' ? '/' : uri.path),headers
        )
        if response == Net::HTTPRedirection && args[:redirect]
          args[:limit] -= 1
          fetch(response['location'], args)
        else
          response
        end
      rescue Timeout::Error
        args[:retries] += 1
        if args[:retries] <= @@retry_limit
          fetch(uri,args)
        else
          Net::HTTPResponse::CODE_CLASS_TO_OBJ['4']
        end
      end
    }
  end

  # Source: http://goo.gl/enmv7
  def get_links(doc)
    (Hpricot(doc)/"a").map{|el| el[:href]}
  end

  # determine if a link should be tested
  def link_is_testable?(uri)
    retval = false
    if [URI::HTTP,URI::HTTPS].include? uri.class 
      retval = !(@@blacklist.include? uri.path) && uri.fragment.nil?
    end
    return retval
  end
end
