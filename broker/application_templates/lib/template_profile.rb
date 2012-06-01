#!/usr/bin/env ruby

require 'socket'
require 'net/http'
require 'yaml'
require 'benchmark'
require 'profile/errors'

DEFAULT_TIMEOUT = 300
DEFAULT_WAIT = 5

class Tests
  attr_accessor :domain, :template, :deploy_opts, :host, :server
  attr_accessor :name, :app

  def initialize(opts)
    opts.each do |k,v|
      send("#{k}=",v)
    end
    debug "Options:"
    debug opts.to_yaml
  end

  def debug(msg)
    $logger.debug msg
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
      status = http.head('/')
      case status
      when Net::HTTPSuccess, Net::HTTPRedirection
        raise Success
      when Net::HTTPServiceUnavailable
        raise ServerError
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
        debug "Retrying, Elapsed: #{Time.now - start} seconds"
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
end

class TestResult
  attr_accessor :name, :result, :time
  def initialize(name,time,result = nil)
    @name = name
    @result = result
    @time = time
  end

  def to_s(len)
    str =  "%#{len}s: %s" % [name.to_s.upcase,fmt_time(time)]
    str += " (#{result})" if result
    str
  end

  private
  def fmt_time(total)
    m = (total/60).floor
    s = (total - (m*60)).floor
    f = ("%.3f" % [total-(m*60)- s]).gsub(/^../,'')
    ("%02d:%02d.%s" % [m,s,f])
  end
end

tries = 0
logfile = (
  begin
    file = "profile#{tries > 0 ? ".#{tries}" : ''}.log"
    throw if File.exists?(file)
    file
  rescue
    tries += 1
    if tries < 10
      retry
    else
      exit
    end
  end
)

s_logger = Logger.new(STDOUT)
s_logger.formatter = proc do |severity, datetime, progname, msg|
  "#{msg}\n"
end

f_logger = Logger.new(logfile('profile'))
f_logger.formatter = proc do |severity, datetime, progname, msg|
  "#{datetime}: #{msg}\n"
end

@loggers = [s_logger,f_logger]

def log(msg = " ")
  @loggers.each{|x| x.debug(msg)}
end

def profile(opts)
  t = Tests.new(opts)
  results = []

  tests = [:deploy,:nslookup,:check_http,:delete]
  max_len = [tests,:total].flatten.map{|x| x.to_s.length}.max

  log
  log "Testing #{t.host}"
  begin
    tests.each do |name|
      result = t.run_test(name)
      log result.to_s(max_len)
      results << result
      if result.result.fatal
        raise result.result
      end
    end
  rescue MyError => e
    if t.app
      t.app.destroy
    end
  end

  total_time = results.map{|r| r.time}.inject{|sum,x| sum + x}
  total = TestResult.new("TOTAL",total_time)
  row = total.to_s(max_len)
  log "-"*row.length
  log row

  errors = results.map{|r| r.result.msg }.compact

  def center(str,max)
    len = str.length + 2
    left = (max - len ) / 2
    right = max - left - len
    "*%s%s%s*" % [" " * left, str, " " * right]
  end

  unless errors.empty?
    padding = 2
    max_err_len = errors.map{|x| x.length}.max + (padding * 2 + 2)
    log
    log "*"*(max_err_len)
    errors.each do |e|
      log center(e,max_err_len)
    end
    log "*"*(max_err_len)
  end
end
