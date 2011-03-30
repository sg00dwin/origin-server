#
# Classes and methods useful for operation and observation of a 
# Red Hat Libra Node
#

require 'rubygems'
require 'nokogiri' # XML processing
require 'json'

#
# Open the password file, find all the entries with the marker in them
# and create a data structure with the usernames of all matching accounts
#
module Libra
  module Node

# ============================================================================
#
# Libra Node Service Status
#
# ============================================================================

    # survey the status of the Libra services on a node
    #   Host
    #   Uptime
    #   Access Controls
    #    SELinux
    #   Messaging
    #     qpid
    #     mcollective
    #   Resource Control
    #     cgconfig
    #     cgred
    #     libra-cgroups
    #     libra-tc
    #     quotas
    #   Service
    #     httpd
    #     user applications

    # Usage Samples
    # s = Status.new
    # s.check :qpid

    class Status

      class << self
        attr_reader :checks, :sebooleans, :sysctl
      end

      @checks = [ 
                 :hostinfo, :filesystems, :sysctl, :selinux, :sebool, 
                 :ntpd, :qpidd, :mcollectived, :cgconfig, :cgred, :httpd 
                ]

      @sebooleans = ["httpd_can_network_relay"]
      @sysctl = ["kernel.sem"]
      
      attr_reader :hostinfo, :ntpd, :qppid, :mcollectived

      def initialize(*checks)
        
        @hostinfo = Libra::Node::HostInfo.new
        @filesystems = Libra::Node::Filesystems.new
        @sysctl = Libra::Node::Sysctl.new self.class.sysctl
        @selinux = Libra::Node::Selinux.new
        @sebool = Libra::Node::SelinuxBoolean.new self.class.sebooleans
        @ntpd = Libra::Node::NtpService.new
        @qpidd = Libra::Node::QpidService.new
        @mcollectived = Libra::Node::McollectiveService.new
        @cgconfig = Libra::Node::CgconfigService.new
        @cgred = Libra::Node::CgredService.new
        @httpd = Libra::Node::HttpdService.new

        checks = self.class.checks if checks.length == 1 and checks[0] == :all
        check(checks)

      end

      def to_s
        # print the header
        title = "Libra Node Status"
        fillcount = (80 - (title.length + 2)) / 2
        out = "=" * fillcount + " " + title + " " + "=" * fillcount + "\n"

        out += @hostinfo.to_s + "\n" if @hostinfo
        out += @filesystems.to_s + "\n" if @filesystems
        out += @sysctl.to_s + "\n" if @sysctl
        out += @selinux.to_s + "\n" if @selinux
        out += @sebool.to_s + "\n" if @sebool
        out += @ntpd.to_s + "\n" if @ntpd
        out += @qpidd.to_s + "\n" if @qpidd
        out += @mcollectived.to_s + "\n" if @mcollectived
        out += @cgconfig.to_s + "\n" if @cgconfig
        out += @cgred.to_s + "\n" if @cgred
        out += @httpd.to_s + "\n" if @httpd

        out += "=" * 80 + "\n"

      end

      def to_xml
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.status {
            xml << @hostinfo.to_xml if @hostinfo
            xml << @filesystems.to_xml if @filesystems
            xml << @sysctl.to_xml if @sysctl
            xml << @selinux.to_xml if @selinux
            xml << @sebool.to_xml if @sebool
            xml << @ntpd.to_xml if @ntpd
            xml << @qpidd.to_xml if @qpidd
            xml << @mcollectived.to_xml if @mcollectived
            xml << @cgconfig.to_xml if @cgconfig
            xml << @cgred.to_xml if @cgred
            xml << @httpd.to_xml if @httpd
          }
        end
        builder.doc.root.to_xml
      end

      def to_json
        hash = {
          "json_class" => self.class.name
        }
        hash['hostinfo'] = @hostinfo.to_json if @hostinfo
        hash['filesystems'] = @filesystems.to_json if @filesystems
        hash['sysctl'] = @sysctl.to_json if @sysctl
        hash['selinux'] = @selinux.to_json if @selinux
        hash['sebool'] = @sebool.to_json if @sebool
        hash['ntpd'] = @ntpd.to_json if @ntpd
        hash['qpidd'] = @qpidd.to_json if @qpidd
        hash['mcollectived'] = @mcollectived.to_json if @mcollectived
        hash['cgconfig'] = @cgconfig.to_json if @cgconfig
        hash['cgred'] = @cgred.to_json if @cgred
        hash['httpd'] = @qpidd.to_json if @httpd
        JSON.generate(hash)
      end

      def self.json_create(o)
        new.init(o)        
      end

      def init(o)
        # set values
        self
      end

      def check(checks=[])
        checks.each do |csym|
          if self.class.checks.index csym == nil
            puts "invalid check #{csym}"
            # raise and exception
          end

          case csym
          when :hostinfo
            @hostinfo.check
          when :filesystems
            @filesystems.check
          when :sysctl
            @sysctl.check
          when :selinux
            @selinux.check
          when :sebool
            @sebool.check
          when :ntpd
            @ntpd.check
          when :qpidd
            @qpidd.check
          when :mcollectived
            @mcollectived.check
          when :cgconfig
            @cgconfig.check
          when :cgred
            @cgred.check
          when :httpd
            @httpd.check
          end
        end
      end

    end

# ============================================================================
#
# Host Information
#
# ============================================================================

    class HostInfo
      
      attr_reader :hostname, :uptime

      def initialize(initcheck=nil)
        if initcheck then check else
          @hostname = nil
          #@uname = nil
          @uptime = nil
        end
      end

      def check
        @hostname = `hostname`.strip
        #@uname = `uname -a`.strip
        @uptime = `uptime`.strip
      end

      def to_s
        out = "-- HostInfo --\n"
        if @hostname then
          out += "  Hostname: #{@hostname}\n"
          out += "  Uptime: #{@uptime}\n"
        end
      end

      def to_xml
        builder = Nokogiri::XML::Builder.new do |xml|
          if @hostname then
            xml.hostinfo(:hostname => @hostname, 
                         :uptime => @uptime)
          end
        end
        builder.doc.root.to_xml
      end

      def to_json
        hash = {
          "json_class" => self.class.name,
        }
        if @hostname then
          hash["hostname"] = @hostname
          hash["uptime"] = @uptime
        end
        JSON.generate(hash)
      end

      def self.json_create(o)
        new.init(o)
      end

      def init(o)
        @hostname = o['hostname']
        @uptime = o['uptime']
        self
      end
    end

# ============================================================================
#
# Filesystems
#
# ============================================================================

    class Filesystems

      def initialize
        @filesystems = nil
      end

      def to_s
        out = "-- File Systems --\n"
        out += "  Filesystem       1K-blocks     Used Available Use% Mounted on\n"
        @filesystems.keys.sort.each do |fsname|
          fs = @filesystems[fsname]
          out += "  %-15s %9s %9s %9s %4s %s\n" % [
          fsname, 
          fs['size'],
          fs['used'], 
          fs['available'],
          fs['percent'],
          fs['mountpoint']
                                                  ]
        end
        out
      end

      def to_xml
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.diskusage {
            @filesystems.keys.sort.each do |fsname|
              fs = @filesystems[fsname]
              xml.filesystem(:fs => fsname,
                             :size => fs['size'],
                             :used => fs['used'], 
                             :available => fs['available'],
                             :percent => fs['percent']) {
                xml.text(fs['mountpoint'])
              }
            end
          }
        end
        builder.doc.root.to_xml
      end

      def to_json
        hash = @filesystems
        hash = {'json_class' => self.class.name, 'filesystems' => @filesystems}
        JSON.generate(hash)
      end

      def self.json_create(o)
        new.init(o)
      end

      def init(o)
        @filesystems = o['filesystems']
        self
      end

      def check
        @filesystems = {}
        input = `df -k | tr -s ' ' 2>&1`
        lines = input.split("\n")
        lines[1..-1].each do |line|
          parts = line.split(" ")
          key = parts[0]
          @filesystems[key] = {
            "size" => parts[1],
            "used" => parts[2],
            "available" => parts[3],
            "percent" => parts[4],
            "mountpoint" => parts[5]
          }          
        end
      end
    end

# ============================================================================
#
# CPU Status
#
# ============================================================================

    class CpuStatus

      def initialize
        
      end

      def to_s

      end

      def to_xml

      end

      def to_json

      end

      def self.json_create(o)
        new.init(o)
      end

      def init(o)

      end

      def check

      end
    end

# ============================================================================
#
# MemoryStatus
#
# ============================================================================

    class MemoryStatus

      def initialize
        
      end

      def to_s

      end

      def to_xml

      end

      def to_json

      end

      def self.json_create(o)
        new.init(o)
      end

      def init(o)

      end

      def check

      end
    end

# ============================================================================
#
# Selinux
#
# ============================================================================
# requires RPM policycoreutils

    class Selinux
      # enable (true|false)
      # enforcing (true|false)
      # type (mls|targeted)
      # policy version
      # booleans

      attr_reader :enabled, :enforcing

      def initialize
        @enabled = nil
        @enforcing = nil
      end

      def to_s
        out = "-- Selinux --\n"
        out += "  Enabled = %s\n" % [ @enabled == nil ? "unknown" : @enabled.to_s ]
        out += "  Enforcing = %s\n" % [ @enforcing = nil ? "unknown": @enforcing.to_s ]
      end

      def to_xml
        builder = Nokogiri::XML::Builder.new do |xml|
          attrs = {}
          attrs['enabled'] = @enabled.to_s if @enabled != nil
          attrs['enforcing'] = @enforcing.to_s if @enforcing != nil
          xml.selinux(attrs)
        end
        builder.doc.root.to_xml        
      end

      def to_json
        hash = {
          "json_class" => self.class.name,
          "enabled" => @enabled,
          "enforcing" => @enforcing
        }
        JSON.generate(hash)
      end

      def self.json_create(o)
        new.init(o)
      end

      def init(o)
        @enabled = o['enabled']
        @enforcing = o['enforcing']
        self
      end

      def check
        response = `getenforce`.strip
        case response
        when "Disabled"
          @enabled = false
        when "Permissive"
          @enabled = true
          @enforcing = false
        when "Enforcing"
          @enabled = true
          @enforcing = true
        end

      end
    end


# =============================================================================
#
#  Guest Account Class
#
# =============================================================================
    class GuestAccount
 
      # Used to find accounts
      @@passwd_file = "/etc/passwd"  # replace with singleton Opts.passwd_file
      def self.passwd_file=(filename)
        @@passwd_file = filename
      end
      @@guest_marker = ":libra guest:" # replace with Opts.guest_marker
 
      attr_reader :username


      def initialize(username)
        @username = username
        @homedir = nil
        @applications = nil
      end

      def to_s
        @username
      end

      def to_xml
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.account(:username => @username)
        end
        builder.doc.root.to_xml
      end
  
      def self.json_create(o)
        new(*o['username'])
      end

      def to_json
        JSON.generate({"json_class" => self.class.name,
                        "username" => @username})
      end

      # find a user's home directory
      def homedir
        return @homedir if @homedir
        File.open(@@passwd_file, "r") do |f|
          while line = f.gets do
            entry = line.split(":")
            return @homedir = entry[5] if entry[0] == @username
          end
        end
      end

      # find the applications associated with this user
      def appnames(homedir=nil)
        return @applications.keys if @applications

        # get the user's home directory
        homedir ||= self.homedir

        # find the git repositories
        apps = []
        Dir[ homedir + "/git/*.git"].each do |gitdir| 
          apps << File.basename(gitdir, ".git")
        end
        apps.sort
      end

      # populate and return the application data structures
      def applications(refresh=false, homedir=nil)
        return @applications if @applications

        apps = {}
        self.appnames.each do |appname|
          apps << Application.new(appname, self)
        end
        @applications = apps
      end
      # ------------------------------------------------------------------------
      # Class Methods
      # ------------------------------------------------------------------------

      # get a list of account names from the password file
      def self.accounts
        userlist = []
        guest_re = Regexp.new(@@guest_marker)
        File.open(@@passwd_file, "r") do |f|
          while line = f.gets
            username = line.split(":")[0]
            if guest_re =~ line
              userlist.push(username)
            end
          end
        end
        userlist
      end

    end

# =============================================================================
#
# Application Class
#
# =============================================================================

    class Application

      attr_reader :appname, :apptype
      attr :account

      def initialize(appname, account=nil, apptype=nil)
        @appname = appname
        @account = account
        @apptype = apptype
      end


      def to_s
        @appname
      end

      def to_xml
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.application(:appname => @appname)
        end
        builder.doc.root.to_xml
      end
  
      def self.json_create(o)
        new(*o['appname'])
      end

      def to_json
        JSON.generate({"json_class" => self.class.name, 
                        "appname" => @appname})
      end

    end
    

# ========================================================================
#
# Generic Service Class
#
# ========================================================================

    class Service

      class << self
        attr_accessor :servicename, :stopped_pattern, :running_pattern
      end

      attr_accessor :installed, :enabled, :running, :message

      @servicename = 'noname'
      @stopped_pattern = /#{@name} is stopped/
      @running_pattern = /#{@name} \(pid (\d+)\) is running/

      @installed = nil
      @enabled = nil
      @running = nil
      @message = nil

      def initialize(args={})
        @servicename = self.class.servicename
        @stopped_pattern = self.class.stopped_pattern
        @running_pattern = self.class.running_pattern
      end

      def to_s
        out = "Service #{@servicename}: "
        case @installed
        when false
          out += "is not installed\n"
        when true
          out += @running ? "  Running\n" : "Stopped\n"
          out += "  Runlevels:"
          (0..6).each do |runlevel|
            out += "  #{runlevel}:#{@enabled[runlevel]}"
          end
          out += "\n"
          out += "  Message: " + @message + "\n"
        when nil
          out += "unknown\n"
        end
        out
      end

      def to_xml
        builder = Nokogiri::XML::Builder.new do |xml|
          attrs = {:name => @servicename}

          attrs[:running] = @running ? "true" : "false" if @running != nil
          
           xml.service(attrs) {
            if @installed == nil then
              xml.text("unknown")
            elsif @enabled == nil then
              xml.text("not installed")
            else
              for num in (0..6) do
                xml.runlevel(:level => num) {
                  xml.text(@enabled[num])
                }
              end
              xml.message {
                xml.text(@message)
              }
            end
          }
        end
        builder.doc.root.to_xml
      end

      def self.json_create(o)
        new.init_json(o)
      end

      def init_json(o)
        @servicename = o['name']
        @installed = o['installed']
        @enabled = o['enabled']
        @running = o['running']
        @message = o['message']
        self
      end
      
      def to_json
        struct = {
          "json_class" => self.class.name,
          "name" => @servicename
        }
        struct['installed'] = @installed
        struct['enabled'] = @enabled if @enabled != nil
        struct['running'] = @running if @running != nil
        struct['message'] = @message if @installed
        JSON.generate(struct)
      end

      def check
        cmd = "chkconfig --list #{@servicename} 2>&1"
        response = `#{cmd}`.strip
        
        if /error reading information on service/ =~ response then
          @installed = false
          @enabled = nil
          @running = nil
          @message = "not installed"
          return
        end

        # parse the config string
        @installed = true
        @enabled = response.split[1..-1].map {|v| v.tr("0-9:", "")}
        @message = `service #{@servicename} status`.strip
        if @running_pattern =~ @message then
          @running = true
        elsif @stopped_pattern =~ @message then
          @running = false
        else
          puts "Unable to determine run state for #{@servicename}"
          p @running_pattern
          p @stopped_pattern
        end           
      end
    end

# ===========================================================================
#
# Specialized Service Classes
#
# ===========================================================================

    # NTP daemon
    class NtpService < Libra::Node::Service
      @servicename = "ntpd"
      @running_pattern = Regexp.new @servicename + '\s+\(pid\s+(\d+)\) is running\.\.\.'
      @stopped_pattern = Regexp.new "#{@servicename} is stopped"

      # TODO: add peer and offset status 
    end

    # check the QPID service
    class QpidService < Libra::Node::Service
      @servicename = "qpidd"
      @running_pattern = Regexp.new @servicename + '\s+\(pid\s+(\d+)\) is running'
      @stopped_pattern = Regexp.new "#{@servicename} is stopped"
    end

    class McollectiveService < Libra::Node::Service
      @servicename = "mcollective"
      @running_pattern = Regexp.new 'mcollectived \s+\((\d+)\) is running'
      @stopped_pattern = /mcollectived is stopped/

      # TODO: add mc-ping (and other?) message status
    end

    class CgconfigService < Libra::Node::Service
      @servicename = "cgconfig"
      @running_pattern = Regexp.new "Running"
      @stopped_pattern = Regexp.new "Stopped"

      # add report on initial setup and status
    end

    class CgredService < Libra::Node::Service
      @servicename = "cgred"
      @running_pattern = Regexp.new @servicename + '\s+\(pid\s+(\d+)\) is running'
      @stopped_pattern = /#{@servicename} is stopped/
    end

    class HttpdService < Libra::Node::Service
      @servicename = "httpd"
      @running_pattern = Regexp.new @servicename + '\s+\(pid\s+(\d+)\) is running'
      @stopped_pattern = /#{@servicename} is stopped/

      # add report of number of daemons, sites served etc
    end


# ============================================================================
#
# Libra User cgroups
#
# ============================================================================

    class UserCgroups

      def initialize
        
      end

      def to_s

      end

      def to_xml

      end

      def to_json

      end

      def self.json_create(o)
        new.init(o)
      end

      def init(o)

      end

      def check

      end
    end

# ============================================================================
#
# User Traffic Control
#
# ============================================================================

    class TrafficControl
      # check: enabled (true|false)
      #        enforcing (true|false)
      #        type (targeted|mls)
      #        policy version
      #        required booleans

      def initialize
        
      end

      def to_s

      end

      def to_xml

      end

      def to_json

      end

      def self.json_create(o)
        new.init(o)
      end

      def init(o)

      end

      def check

      end
    end


# ============================================================================
#
# File system quotas
#
# ============================================================================

    class FilesystemQuotas

      @fspattern = /user quota on ([^ ]+) \([^)]+\) is (on|off)/
      @fsformat = "  %-15s%-15s %-3s\n"
      class << self
        attr_reader :fspattern, :fsformat
      end

      attr_reader :filesystems

      def initialize
        @filesystems = {}
      end

      def to_s
        out = "-- Filesystem Quotas --\n"
        if @filesystems.keys.length == 0 then
          out += "  no quotas enabled"
        else
          out += "  Filesystem     Device          Status\n"
          @filesystems.keys.sort.each do |fsname|
            fs = @filesystems[fsname]
            out += self.class.fsformat % [fsname, fs[:device], fs[:status]] 
          end
        end
        out        
      end

      def to_xml
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.quotas {
            @filesystems.keys.sort.each do |fsname|
              attrs = {
                :name => fsname,
                :device => @filesystems[fsname][:device],
                :status => @filesystems[fsname][:status]
              }
              xml.filesystem(attrs)
            end
          }
        end
        builder.doc.root.to_xml
      end

      def to_json
        fslist = []
        
        hash = {
          :json_class => self.class.name,
          :filesystems => fslist 
        }
        @filesystems.keys.sort.each do |fsname|
          fs = @filesystems[fsname]
          fslist << {
            :name => fsname,
            :device => fs[:device],
            :status => fs[:status]
          }
        end
        p self

        json = JSON.generate(hash)
        json
      end

      def self.json_create(o)
        new.init(o)
      end

      def init(o)
        p o
        o[:filesystems].each do |fs|
          @filesystems[fs[:name]] = {
            :device => fs[:device],
            :status => fs[:status]
          }
        end
        self
      end

      def check
        # list the filesystems with quotas and their initialzation status
        response = `quotaon -u -p -a`
        lines = response.split("\n")
        lines.each do |line|
          fs, dev, status = Regexp.last_match[1..3]
          @filesystems[fs] = {:device => dev, :status => status }
        end
      end
    end


# ============================================================================
#
# System Kernel Settings (sysctl)
#
# ============================================================================

    class Sysctl < Hash
      
      def initialize(keys=[])
        super
        keys.each do |key|
          self[key] = nil
        end
      end

      def to_s
        out = "-- Sysctl --\n"
        names = self.keys
        names.sort.each do |key|
          out += "  #{key} = #{self[key]}\n"
        end
        out
      end

      def to_xml
        builder = Nokogiri::XML::Builder.new do |xml|
           xml.sysctl {
            self.keys.sort.each do |key|
              xml.setting(:name => key) {
                xml.text(self[key])
              }
            end
          }
        end
        builder.doc.root.to_xml
      end

      def to_json
        struct = {
          "json_class" => self.class.name,
          "sysctl" => {}
        }

        self.keys.sort.each do |key|
          struct["sysctl"][key] = self[key]
        end
        JSON.generate(struct)
      end

      def self.json_create(o)
        new.init(o)
      end

      def init(o)
        o['sysctl'].each do |key|
          self[key] = o['sysctl'][key]
        end
      end

      def check
        # these should be class or class instance variables
        pattern = Regexp.new "([^ ]+) = (.*)"
        error_pattern = Regexp.new "error:\s+(.*) on key '(.*)'"
        unknown_pattern = Regexp.new "error: \".*\" is an unknown key"

        if self.length == 0 then
          # get everything
          response = `sysctl -a 2>&1`
          lines = response.split("\n")
          lines.each do |line|
            if pattern =~ line then
              key = Regexp.last_match(1)
              value = Regexp.last_match(2)
              self[key] = value
            elsif error_pattern =~ line
              error_message = Regexp.last_match(1)
              key = Regexp.last_match(2)
              
              self[key] = "error: " + error_message
            else
              puts "sysctl NO match for #{line}"
            end
          end
        else

          # get values for each requested key
          self.keys.each do |key|
            line = `sysctl #{key} 2>&1`.strip
            if pattern =~ line then
              key = Regexp.last_match(1)
              value = Regexp.last_match(2)
              self[key] = value                          
            elsif error_pattern =~ line
              self[key] = error_pattern(1)
            elsif unknown_pattern =~ line
              self[key] = "error: unknown key"
            end
          end
        end
      end
    end

# ============================================================================
#
# System Kernel Settings (sysctl)
#
# ============================================================================

    class SelinuxBoolean < Hash
      
      def initialize(keys=[])
        super
        keys.each do |key|
          self[key] = nil
        end
      end

      def to_s
        out = "-- Selinux Booleans --\n"
        names = self.keys
        names.sort.each do |key|
          out += "  #{key} = #{self[key]}\n"
        end
        out
      end

      def to_xml
        builder = Nokogiri::XML::Builder.new do |xml|
           xml.sebool {
            self.keys.sort.each do |key|
              xml.boolean(:name => key, :value => self[key])
            end
          }
        end
        builder.doc.root.to_xml
      end

      def to_json
        struct = {
          "json_class" => self.class.name,
          "sebool" => {}
        }

        self.keys.sort.each do |key|
          struct["sebool"][key] = self[key]
        end
        JSON.generate(struct)
      end

      def self.json_create(o)
        new.init(o)
      end

      def init(o)
        o['sebool'].each do |key|
          self[key] = o['sebool'][key]
        end
      end

      def check
        # these should be class or class instance variables
        pattern = Regexp.new "([^ ]+) --> (.*)"
        error_pattern = Regexp.new "Error getting active value for (.*)"
        disabled_pattern = Regexp.new "getsebool:\s+SELinux is disabled"

        if self.length == 0 then
          # get everything
          response = `getsebool -a 2>&1`
          lines = response.split("\n")
          lines.each do |line|
            if pattern =~ line then
              key = Regexp.last_match(1)
              value = Regexp.last_match(2)
              self[key] = value
            elsif error_pattern =~ line
              error_message = Regexp.last_match(1)
              key = Regexp.last_match(2)
              
              self[key] = "error: " + error_message
            elsif disabled_pattern =~ line
              return nil
            else
              puts "Selinux: NO match for #{line}"
            end
          end
        else

          # get values for each requested key
          self.keys.each do |key|
            line = `getsebool #{key} 2>&1`.strip
            if pattern =~ line then
              key = Regexp.last_match(1)
              value = Regexp.last_match(2)
              self[key] = value                          
            elsif error_pattern =~ line
              self[key] = error_pattern(1)
            end
          end
        end
      end
    end

  end
end
