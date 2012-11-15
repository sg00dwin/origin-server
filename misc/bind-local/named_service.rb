#!/usr/bin/env ruby
#
# Control a BIND DNS service for testing
#


require 'rubygems'
require 'open4'
require 'ftools' # adds File.cp
require 'fileutils' # for change directory
require 'pp'

require 'dnsruby'

named_dir = File.dirname(__FILE__)

class BindTestService

  attr_reader :testroot, :pid
  def initialize(testroot=named_dir)

    @testroot = testroot

    # get server, port, keyname, keyvalue, zone, domain_suffix
    reset
  end

  def clean
    begin
      cwd = FileUtils.pwd
      FileUtils.cd @testroot

      # delete all journal files
      `rm -f tmp/*.jnl`

      # delete the dynamic managed keys file
      if File.exists? 'tmp/managed-keys.bind'
        File.delete 'tmp/managed-keys.bind'
      end

    ensure
      FileUtils.cd cwd
    end
  end

  def reset
    clean
    begin
      cwd = FileUtils.pwd
      FileUtils.cd @testroot
      if not File.exists?("tmp")
        FileUtils.mkdir("tmp")
      end
      #File.copy("named.conf.init", "named.conf")
      # copy the initial example.db in place
      File.copy("example.com.db.init", "tmp/example.com.db")

    ensure
      FileUtils.cd cwd
    end
  end

  # start the daemon
  def start(forward=false)

    if @pid != nil
      raise "I think a named is already running with PID #{@pid}"
    end

    begin
      cwd = FileUtils.pwd
      FileUtils.cd @testroot

      if forward
        @ns = BindTestService.nameserver

	text = File.read('named.conf')

 	# enable recursion
        # text.gsub!(/i\/\/ (recursion)/, "\\1")
        # enable forwarding
	text.gsub!(/\/\/ (forward first)/, "\\1")
        text.gsub!(/\/\/ (forwarders)/, "\\1")
        # replace __FORWARDER__ with nameserver
	text.gsub!(/__FORWARDER__/, @ns)
	
	File.open('named.conf', 'w') { |f| f.write(text) ; f.close }
 
        # update nameserver in /etc/resolv.conf
        BindTestService.nameserver = "127.0.0.1"	 
      end

      begin
        pid, stdin, stdout, stderr = Open4::popen4 "/usr/sbin/named -4 -c named.conf"
     
        # Need to check if there already is one

        stdin.close
        stdout.close
        stderr.close

        sleep 2
        @pid = File.open("tmp/named.pid").read.to_i
      ensure
        FileUtils.cd cwd
      end
    end
  end

  def stop
    if @pid == nil
      raise "no PID: is there really a named running?"
    end

    Process.kill('INT', @pid)
    @pid = nil

    ns = BindTestService.original_name_server
    if ns
      BindTestService.nameserver = ns
    end 
  end

  def self.stop(named_root)
    pid = File.read("#{named_root}/tmp/named.pid").strip.to_i
    Process.kill('INT', pid)
  end

  def self.clean(named_root)
    FileUtils.cd named_root
    `rm -f tmp/*`
  end

  # get original nameserver from /etc/resolv/conf
  def self.original_nameserver
    File.read("/etc/resolv.conf").match(/\nnameserver\s+([^\s]+) # restore\n/m)[1]
  end

  # get the nameserver list from /etc/resolv.conf
  def self.nameserver
    # only works for ONE nameserver
    File.read("/etc/resolv.conf").match(/\nnameserver\s+([^\s]+)\n/m)[1]
  end
  
  def self.nameserver=(ipaddr, mark=false)
    # replace the nameserver in /etc/resolv.conf with a new value
    text = File.read("/etc/resolv.conf")

    # is it already set? return
    return if text.match(/^nameserver\s+#{ipaddr}/)

    # comment all existing ones
    text.gsub!(/\n(nameserver\s+([^\s]+))\n/m, "\n# \\1 # restore\n")

    # uncomment the one we want (if it exists)
    pattern = /\n# (nameserver #{ipaddr}( #restore)?\n)/m
    puts "pattern = #{pattern}"
    found = text.gsub!(pattern, "\n\\1")

    pp found

    text << "nameserver #{ipaddr}\n" if ! found

    File.open("/etc/resolv.conf", 'w') { |f| f.write(text) }
  end
end

if __FILE__ == $0
  # UPDATE AS NEEDED

  case ARGV[0]
  when "start"
    c = BindTestService.new named_dir

    c.reset

    forward = ARGV[1] == "forward"
    c.start forward

  when "stop"
    BindTestService.stop named_dir

  when "clean"
    BindTestService.clean named_dir

  when "resolv"
    BindTestService.nameserver = ARGV[1]
  else

  end
end

