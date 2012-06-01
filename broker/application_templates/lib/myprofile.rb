#!/usr/bin/env ruby

require 'socket'
require 'net/http'
require 'yaml'
require 'benchmark'

require 'profile/errors'
require 'profile/mylogger'
require 'profile/results'

DEFAULT_TIMEOUT = 300
DEFAULT_WAIT = 10

class Profile
  include MyLogger
  attr_accessor :domain, :template, :deploy_opts, :host, :url_base
  attr_accessor :name, :app, :tests, :results, :type

  def initialize(opts)
    opts.each do |k,v|
      send("#{k}=",v)
    end

    @name    = String.random(5)
    @results = TestResultSet.new(tests)
    @host    = "%s-%s.%s" % [name,domain.id,url_base]

    debug "Options:"
    debug opts.merge({
      :host => host
    }).to_yaml
  end

  def start_func(msg)
    if @first
      @first = false
      debug msg
    end
  end

  def deploy
    start_func("Deploying application #{name} with \n#{deploy_opts.to_yaml}")
    if domain
      @app = domain.add_application(name,deploy_opts)
      raise Success
    else
      raise NoCredentialsError
    end
  end

  def nslookup
    start_func "Checking DNS for #{host}"
    begin
      Socket.gethostbyname(host)
      raise Success
    rescue SocketError
      raise DNSError
    end
  end

  def check_http
    start_func "Checking HTTP for #{host}"
    Net::HTTP.start(host,80) do |http|
      begin
        status = http.head('/')
        case status
        when Net::HTTPSuccess, Net::HTTPRedirection
          raise Success
        when Net::HTTPServiceUnavailable
          raise ServerError
        end
      rescue SocketError
        raise DNSError
      end

      raise FatalServerError
    end
  end

  def delete
    start_func "Deleting app"
    @app.delete
    raise Success
  end

  def _retry
    @first = true
    start = Time.now
    begin
      yield
    rescue MyError => e
      if (e.retry && check_time(start,e))
        debug "Retrying, Elapsed: %.3f seconds" % (Time.now - start)
        retry
      else
        debug "Giving up: #{e}"
        return e
      end
    rescue Rhc::Rest::ValidationException => e
      debug "Failure: #{e}: #{e.message}"
      return RestException.new(e.message)
    rescue Exception => e
      debug "Failure: #{e}: #{e.message}"
      return UnknownException.new("#{e}: #{e.message}")
    end
  end

  def check_time(start,err)
    sleep err.wait
    Time.now - start < err.timeout
  end

  def run_test(name)
    time = Benchmark.realtime { @result = _retry{ send(name) } }
    TestResult.new(name,time,@result)
  end

  def run
    puts
    puts "Testing %s (%s)" % [host,type.to_s]
    begin
      tests.each do |name|
        result = run_test(name)
        results << result
        if result.result.fatal
          raise result.result
        end
      end
    rescue MyError => e
      if app
        app.destroy
      end
    end

    results.finish
  end
end
