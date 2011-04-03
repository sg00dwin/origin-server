#
# Classes and methods useful for operation and observation of a 
# Red Hat Libra Node
#

require 'rubygems'
require 'nokogiri' # XML processing
require 'json'

# require 'libra/node/hostinfo'
# require 'libra/node/filesystems'
# require 'libra/node/quotas'
# require 'libra/node/sysctl'
# require 'libra/node/selinux'
# require 'libra/node/sebool'
# require 'libra/node/services'
# require 'libra/node/usercgroups'
# require 'libra/node/tc'
#
# require 'libra/node/account'
# require 'libra/node/application'
#

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
        attr_reader :checks, :sebooleans, :sysctl, :packages
      end

      @checks = [ 
                 :hostinfo, :filesystems, :quotas, :sysctl, :selinux, :sebool, 
                 :ntpd, :qpidd, :mcollectived, :cgconfig, :cgred, :httpd,
                 :cgroups, :tc, :software
                ]

      @sebooleans = ["httpd_can_network_relay"]
      @sysctl = ["kernel.sem"]
      @packages = ["li", "li-common", "li-node", "li-node-tools", "li-server",
                   "li-cartridge-php-5.3.2", "li-cartridge-wsgi-3.2.1", 
                   "li-cartridge-rack-1.1.0"]
      
      attr_reader :hostinfo, :ntpd, :qppid, :mcollectived

      def initialize(*checks)
        
        @hostinfo = Libra::Node::HostInfo.new
        @filesystems = Libra::Node::Filesystems.new
        @quotas = Libra::Node::FilesystemQuotas.new
        @sysctl = Libra::Node::Sysctl.new self.class.sysctl
        @selinux = Libra::Node::Selinux.new
        @sebool = Libra::Node::SelinuxBoolean.new self.class.sebooleans
        @ntpd = Libra::Node::NtpService.new
        @qpidd = Libra::Node::QpidService.new
        @mcollectived = Libra::Node::McollectiveService.new
        @cgconfig = Libra::Node::CgconfigService.new
        @cgred = Libra::Node::CgredService.new
        @httpd = Libra::Node::HttpdService.new
        @cgroups = Libra::Node::CgroupsConfiguration.new
        @tc = Libra::Node::TrafficControl.new
        @software = Libra::Node::SoftwarePackages.new self.class.packages

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
        out += @quotas.to_s + "\n" if @quotas
        out += @sysctl.to_s + "\n" if @sysctl
        out += @selinux.to_s + "\n" if @selinux
        out += @sebool.to_s + "\n" if @sebool
        out += @ntpd.to_s + "\n" if @ntpd
        out += @qpidd.to_s + "\n" if @qpidd
        out += @mcollectived.to_s + "\n" if @mcollectived
        out += @cgconfig.to_s + "\n" if @cgconfig
        out += @cgred.to_s + "\n" if @cgred
        out += @httpd.to_s + "\n" if @httpd
        out += @cgroups.to_s + "\n" if @cgroups
        out += @tc.to_s + "\n" if @tc
        out += @software.to_s + "\n" if @software

        out += "=" * 80 + "\n"

      end

      def to_xml
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.status {
            xml << @hostinfo.to_xml if @hostinfo
            xml << @filesystems.to_xml if @filesystems
            xml << @quotas.to_xml if @quotas
            xml << @sysctl.to_xml if @sysctl
            xml << @selinux.to_xml if @selinux
            xml << @sebool.to_xml if @sebool
            xml << @ntpd.to_xml if @ntpd
            xml << @qpidd.to_xml if @qpidd
            xml << @mcollectived.to_xml if @mcollectived
            xml << @cgconfig.to_xml if @cgconfig
            xml << @cgred.to_xml if @cgred
            xml << @httpd.to_xml if @httpd
            xml << @cgroups.to_xml if @cgroups
            xml << @tc.to_xml if @tc
            xml << @software.to_xml if @software
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
        hash['quotas'] = @quotas.to_json if @quotas
        hash['sysctl'] = @sysctl.to_json if @sysctl
        hash['selinux'] = @selinux.to_json if @selinux
        hash['sebool'] = @sebool.to_json if @sebool
        hash['ntpd'] = @ntpd.to_json if @ntpd
        hash['qpidd'] = @qpidd.to_json if @qpidd
        hash['mcollectived'] = @mcollectived.to_json if @mcollectived
        hash['cgconfig'] = @cgconfig.to_json if @cgconfig
        hash['cgred'] = @cgred.to_json if @cgred
        hash['httpd'] = @qpidd.to_json if @httpd
        hash['cgroups'] = @cgroups.to_json if @cgroups
        hash['tc'] = @tc.to_json if @tc
        hash['software'] = @software.to_json if @software
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
          when :quotas
            @quotas.check
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
          when :cgroups
            @cgroups.check
          when :tc
            @tc.check
          when :software
            @software.check
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

        # check blocks used/free
        input = `df -k | tr -s ' ' 2>&1`
        # unwrap lines that have wrapped
        input.gsub(/\n\s/m, "")
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

        # check inodes used/free
        input = `df -i | tr -s ' ' 2>&1`
        input.gsub(/\n\s/m, "")
        lines = input.split("\n")
        lines[1..-1].each do |line|
          parts = line.split(" ")
          key = parts[0]
          # set the inodes used and free for each key
        end
      end
    end

# ============================================================================
#
# CPU Status
#
#  CPU count
#  Thread count
#  CPU Characteristics
#  CPU Usage (current, dynamic)
#  CPU Usage statistics: total
#  CPU Usage statistics: All libra
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
#   memory available
#   memory used (total)
#   memory used (libra cgroups?)
#   swap available
#   swap used (total)
#   swap used (libra cgroups?)
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
        out += "  Enforcing = %s\n" % [ @enforcing == nil ? "not applicable": @enforcing.to_s ] 
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


# ============================================================================
#
# SoftwarePackages
#
# ============================================================================

    class SoftwarePackages

      class << self
        attr_reader :rpm_query_format, :rpm_query_re, :rpm_not_installed_re
        attr_reader :rpm_format
      end

      @rpm_query_format = "%{NAME} %{VERSION} %{RELEASE} %{ARCH} %{INSTALLTIME}\n"
      @rpm_query_re = /([^\s]+) ([^\s]+) ([^\s]+) ([^\s]+) (\d+)/
      @rpm_not_installed_re = /package (\w+) is not installed/
      @rpm_format = "  %s-%s-%s.%s\n"

      attr_reader :packages

      def initialize(packages)
        @packages = {}
        packages.each do |name|
          @packages[name] = nil
        end
      end

      def to_s
        out = "-- Software Packages --\n"
        @packages.keys.sort.each do |name|
          pkg = @packages[name]
          if pkg and pkg['version'] then
            out += "  #{name}-#{pkg['version']}-#{pkg['release']}.#{pkg['arch']}\n"
          else
            out += "  #{name} not installed\n"
          end
        end
        out
      end

      def to_xml
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.packages {
            @packages.keys.sort.each do |name|
              pkg = @packages[name]
              xml.rpm pkg.merge({"name" => name})
            end
          }
        end
        builder.doc.root.to_xml        
      end

      def to_json
        hash = {
          "json_class" => self.class.name,
          "packages" => @packages
        }
        JSON.generate(hash)
      end

      def json_create
        new.init(o)
      end

      def init(o)
        o['packages'].each do |pkg|
          name = pkg["name"]
          pkg.delete name
          @packages[name] = pkg
        end
        self
      end

      def check
        @packages.keys.sort.each do |name|
          pkgline = `rpm -q --qf \"#{self.class.rpm_query_format}\" #{name}`.strip
          self.class.rpm_query_re =~ pkgline
          if Regexp.last_match != nil then
            pkginfo = Regexp.last_match[1..-1]
            pkg = {
              "version" => pkginfo[1],
              "release" => pkginfo[2],
              "arch" => pkginfo[3],
              # convert this to ruby date?
              "installtime" => pkginfo[4]
            }
            @packages[name] = pkg
          else
            self.class.rpm_not_installed_re =~ pkgline
            if Regexp.last_match != nil then
              @packages[name] = {}
            end
          end
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
      @running_pattern = Regexp.new 'mcollectived\s+\((\d+)\) is running'
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
# Libra Cgroups Configuration
#
# ============================================================================

    class CgroupsConfiguration
      #
      # Check the initialization for User cgroups for libra:
      #   1) cgroups mounted on /cgroup
      #   2) all subsystems mounted on /cgroup/all (/)
      #   3) all subsystems mounted on /cgroup/all/libra (/libra)
      #   4) for each libra guest, /libra/<username> does not exist or
      #      does not have the required subsystems
      # 

      class << self
        attr_reader :subsystems
      end

      @subsystems = ["cpu", "cpuacct", "memory", "freezer", "net_cls", 
                     "devices", "blkio" , "ns"]

      attr_reader :mounts

      def initialize
        @mounts = nil
        @libra_initialized = nil
        @num_users = 0
      end

      def to_s
        out = "-- Cgroup Configuration --\n"

        # don't bother if there's nothing to report
        return out += "  no subsystems mounted\n"  if mounts == nil
        
        @mounts.keys.sort.each do |mntpoint|
          out += "  #{mntpoint} #{@mounts[mntpoint].sort!.join(',')}\n"
        end

        # check if libra is mounted
        if @libra_initialized then
          out += "\n  Libra cgroups initialized: #{@num_users} users\n"
        else
          out += "\n  Libra cgroups not initialized\n"
        end
        out
      end

      def to_xml
        builder = Nokogiri::XML::Builder.new do |xml|
          attrs = {
            "libra_initialized" =>  @libra_initialized ? "true" : "false",
            "num_users" => @num_users
          }
          xml.cgroups(attrs){
            @mounts.keys.sort.each do |mtpoint|
              xml.mount("mountpoint" => mtpoint) {
                @mounts[mtpoint].sort.each do |subsystem|
                  xml.subsystem {
                    xml.text(subsystem)
                  }
                end
              }
            end
          }
        end
        builder.doc.root.to_xml        
      end

      def to_json
        hash = {"json_class" => self.class.name}
        hash["mounts"] = @mounts
        hash["libra_initialized"] = @libra_initialized ? "true" : "false"
        hash["num_users"] = @num_users
        JSON.generate(hash)
      end

      def self.json_create(o)
        new.init(o)
      end

      def init(o)
        @mounts = o['mounts']
        @libra_initialized = o['libra_initialized'] == "true"
        @num_users = o['num_users']
        self
      end

      def check
        @mounts = get_mounts
        status = `service libra-cgroups status 2>&1 | grep "Libra cgroups "`.strip
        /Libra cgroups initialized/ =~ status
        @libra_initialized = Regexp.last_match != nil
        @num_users = Integer(`lscgroup | grep :/libra/ | wc -l`.strip)
      end

      def get_mounts
        # check that it's mounted properly
        cgmounts = `grep cgroup /proc/mounts`
        cgmountlines = cgmounts.split("\n")
        mounts = {}
        cgmountlines.each do |line|
          # dev mtpoint type options dumpfreq fsckpass
          dev, mtpoint, type, optstr, dumpfreq, fsckpass  = line.split(" ")
          options = optstr.split(",")
          subsystems = []
          options.each do |name|
            if self.class.subsystems.index(name) then
              subsystems << name
              options.delete(name)
            end
          end
          mounts[mtpoint] = subsystems
        end
        mounts
      end
    end

# ============================================================================
#
# User Traffic Control
#
# ============================================================================

    class TrafficControl
      # check: enabled (true|false)
      # qdisc dev eth0 
      # class dev eth0 classid 1:1
      # class dev eth0 parent classid 1:1 (count)

      # from libra-tc
      # USERNAME=$1
      # Display status of traffic control status.
      #if [ -z "$1" ]
      #then
      #  $TC -s qdisc show dev $tc_if
      #  $TC -s class show dev $tc_if classid 1:1
      #else
      #  USERID=`uid $1`
      #  NETCLASS=`netclass $USERID`
      #  $TC -s class show dev $$tc_if classid 1:${NETCLASS}
      #fi

      class << self
        attr_accessor :tc, :interface, :classroot
        attr_reader :qdisc_type_re
        attr_reader :qdisc_htb_format, :qdisc_htb_re, :qdisc_htb_stats_re
        attr_reader :htb_class_format, :htb_class_re, :htb_class_stats_re
      end

      @tc = "/sbin/tc"
      @qdisc = "htb"
      @interface = "eth0"
      @classroot = "1:1"
      @qdisc_type_re = /^qdisc (\S+)/
      @qdisc_htb_format = "  qdisc htb %s %s refcnt %d r2q %d default %d direct_packets_stat %d\n"
      @qdisc_htb_re = /qdisc (\S+) ([\da-f]+:[\da-f]*) (\S+) refcnt (\d+) r2q (\d+) default (\d+) direct_packets_stat (\d+)/
      @qdisc_htb_stats_re = //
      @htb_class_format = "  class %s %s %s prio %d rate %s ceil %s burst %s cburst %s\n"
      @htb_class_re = /class (\S+) ([\da-f]+:[\da-f]*) (root|parent ([\da-f]+:[\da-f]*))( prio (\d+))? rate (\S+) ceil (\S+) burst (\S+) cburst (\S+)/
      @htb_class_stats_re = //

      def initialize
        @qdisc = nil
        @rootclass = nil
        #@childclasses = nil
      end

      def to_s
        out = "-- Traffic Control --\n"

        # if we don't know, say so
        if @qdisc == nil then
          out += "  unknown\n"
          return out
        end

        # if the qdisc is not htb, then bail
        if @qdisc["type"] != "htb" then
          out += "  qdisc #{@qdisc['type']} - libra unsupported qdisc\n"
          return out
        end

        return out

        # no, don't report these
        if @childclasses != nil then
          @childclasses.keys.sort.each do |clsid|
            cls = @childclasses[clsid]
            out += self.class.htb_class_format % [cls['qdisc'],
                                                  cls["classid"],
                                                  cls["parent"],
                                                  cls["prio"],
                                                  cls["rate"],
                                                  cls["ceil"],
                                                  cls["burst"],
                                                  cls["cburst"]
                                                 ]
          end
        end
        out
      end

      def to_xml
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.tc {
            attrs = {
              "type" => @qdisc["type"]
            }
            if @qdisc['type'] == "htb" then
              attrs.merge({
                "classid" => @qdisc["classid"],
                "parent" => @qdisc["parent"],
                "refcnt" => @qdisc["refcnt"],
                "r2q" => @qdisc["r2q"],
                "default" => @qdisc["default"],
                "direct_packets_stat" => @qdisc["direct_packets_stat"]
              })
            end
            xml.qdesc(attrs)

            attrs = {
              'qdisc' => @rootclass['qdisc'],
              'classid' => @rootclass['classid'],
              'parent' => @rootclass['parent'],
              'prio' => @rootclass['prio'],
              'rate' => @rootclass['rate'],
              'ceil' => @rootclass['ceil'],
              'burst' => @rootclass['burst'],
              'cburst' => @rootclass['burst']
            } if @rootclass
            xml.rootclass(attrs) if @rootclass

            if @childclasses != nil then
              @childclasses.keys.sort.each do |clsid|
                cls = @childclasses[clsid]
                attrs = {
                  'qdisc' => cls['qdisc'],
                  'classid' => cls['classid'],
                  'parent' => cls['parent'],
                  'prio' => cls['prio'],
                  'rate' => cls['rate'],
                  'ceil' => cls['ceil'],
                  'burst' => cls['burst'],
                  'cburst' => cls['burst']
                }
                xml.class_(attrs)
              end
            end
          }
        end
        builder.doc.root.to_xml
      end

      def to_json
        hash = {"json_class" => self.class.name}
        hash["qdisc"] = @qdisc
        hash["rootclass"] = @rootclass
        if @childclasses != nil then
          hash["childclasses"] = @childclasses
        end
        JSON.generate(hash)
      end

      def self.json_create(o)
        new.init(o)
      end

      def init(o)
        # convert to symbols
        @qdisc = o['qdisc']
        @rootclass = o['rootclass']
        @childclasses = o['childclasses']
        self
      end

      def check
        # check for the htb qdisc on eth0
        tc_cmd = "%s qdisc show dev %s" % [self.class.tc, self.class.interface]
        qdiscline = `#{tc_cmd}`.strip

        # check the qdisc type
        self.class.qdisc_type_re =~ qdiscline
        qdisc_type = Regexp.last_match[1]
        if qdisc_type != "htb" then
          @qdisc = {"type" => qdisc_type}
          return self
        end

        # check for the root htb class on eth0
        self.class.qdisc_re =~ qdiscline
        matches = Regexp.last_match
        if matches == nil
          # no qdisc matching an htb format
          return nil
        end
        qdisc = matches[1..-1]
        if qdisc == nil
          return nil
        end
        @qdisc = {
          "type" => qdisc[1], 
          "classid" => qdisc[2],
          "parent" => qdisc[3],
          "refcnt" => Integer(qdisc[4]),
          "r2q" => Integer(qdisc[5]),
          "default" => Integer(qdisc[6]),
          "direct_packets_stat" => Integer(qdisc[7]),
        }

        tc_cmd = "%s class show dev %s classid %s" % [self.class.tc,
                                                      self.class.interface,
                                                      self.class.classroot]
        tcrootline = `#{tc_cmd}`.split
        self.class.class_re =~ tcrootline
        tcclass = Regexp.last_match[1..-1]
        rootclass = {
          "qdisc" => tcclass[0],
          "classid" => tcclass[1],
          "parent" => tcclass[2] == "root" ? "root" : tcclass[3],
          "prio" => tcclass[5],
          "rate" => tcclass[6],
          "ceil" => tcclass[7],
          "burst" => tcclass[8],
          "cburst" => tcclass[9]
        }

        tc_cmd = "%s class show dev %s parent %s" % [self.class.tc,
                                                     self.class.interface,
                                                     self.class.classroot]
        tcclassout = `#{tc_cmd}`
        tcclasslines = tcclassout.split("\n")
        @childclasses = {}
        tcclasslines.each do |line|
          tcclass = Regexp.last_match[1..-1]
          @childclasses[classid] = {
            "qdisc" => tcclass[0],
            "classid" => tcclass[1],
            "parent" => tcclass[2] == "root" ? "root" : tcclass[3],
            "prio" => Integer(tcclass[5]),
            "rate" => tcclass[6],
            "ceil" => tcclass[7],
            "burst" => tcclass[8],
            "cburst" => tcclass[9]
          }
        end
        
        # count the child htb classes on 

      end
    end


# ============================================================================
#
# File system quotas
#
# ============================================================================

    class FilesystemQuotas

      class << self
        attr_reader :fspattern, :fsformat
      end

      @fspattern = /user quota on ([^ ]+) \(([^)]+)\) is (on|off)/
      @fsformat = "  %-15s%-15s %-3s\n"


      attr_reader :filesystems

      def initialize
        @filesystems = {}
      end

      def to_s
        out = "-- Filesystem Quotas --\n"
        if @filesystems.keys.length == 0 then
          out += "  no quotas enabled\n"
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
                "name" => fsname,
                "device" => @filesystems[fsname][:device],
                "status" => @filesystems[fsname][:status]
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
          "json_class" => self.class.name,
          "filesystems" => fslist 
        }
        @filesystems.keys.sort.each do |fsname|
          fs = @filesystems[fsname]
          fslist << {
            "name" => fsname,
            "device" => fs[:device],
            "status" => fs[:status]
          }
        end
        json = JSON.generate(hash)
      end

      def self.json_create(o)
        new.init(o)
      end

      def init(o)
        o["filesystems"].each do |fs|
          @filesystems[fs["name"]] = {
            :device => fs["device"],
            :status => fs["status"]
          }
        end
        self
      end

      def check
        # list the filesystems with quotas and their initialzation status
        response = `quotaon -u -p -a`
        lines = response.split("\n")
        lines.each do |line|
          self.class.fspattern =~ line
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
          if self[key] != nil then
            out += "  #{key} = %s\n" % [self[key].to_s]
          else
            out += "  #{key} = unknown\n"
          end
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
              self[key] = nil
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
            elsif disabled_pattern =~ line
              self[key] = nil
              return nil
            end
          end
        end
      end
    end

  end
end
