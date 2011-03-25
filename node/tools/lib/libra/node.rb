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
        attr_reader :checks
      end

      @checks = [:hostinfo]
      
      def initialize(*checks)

        @hostinfo = HostInfo.new

        checks = self.class.checks if checks.length == 1 and checks[0] == :all
        checks.each do |csym|
          if not self.class.checks.member? csym then
            puts "invalid check symbol " + csym.to_s
            # raise an exception
          end

          # continue processing
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
        @hostname = `hostname`
        #@uname = `uname -a`
        @uptime = `uptime`
      end

      def to_s
        out = "-- HostInfo --\n"
        if @hostname then
          out += "  Hostname: #{@hostname}\n"
          out += "  Uptime: #{@uptime}\n"
        end
        out += "\n"
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
        attr_accessor :servicename, :stop_pattern, :running_pattern
      end

      attr_accessor :installed, :enabled, :running, :message

      @servicename = 'noname'
      @stop_pattern = /#{@name} is stopped/
      @running_pattern = /#{@name} \(pid (%d+)\) is running/

      @installed = nil
      @enabled = nil
      @running = nil
      @message = nil

      def initialize(args={})
        @servicename = args[:servicename] || self.class.servicename
        @stop_pattern = args[:stop_pattern] || self.class.stop_pattern
        @running_pattern = args[:running_pattern] || self.class.running_pattern
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
              xml.message = @message
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
        @running = o['running']
        @enabled = o['enabled']
        @message = o['message']
        self
      end
      
      public

      def to_json
        struct = {
          "json_class" => self.class.name,
          "name" => @servicename
        }
        struct['installed'] = @installed if @installed != nil
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
        @installed = true

        # parse the config string
        @enabled = response.split[1..-1].map {|v| v.tr("0-9:", "")}
        @message = `service #{@servicename} status`.strip
        if @stopped_pattern =~ @message then
          @running = false
        else
          @running = true
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
    end

    # check the QPID service
    class QpidService < Libra::Node::Service
      @servicename = "qppid"
    end

    class McollectiveService < Libra::Node::Service
      @servicename = "mcollectived"
    end

    class CgconfigService < Libra::Node::Service
      @servicename = "cgconfig"
      @running_pattern = /Running/
      @stopped_pattern = /Stopped/
    end

    class CgRedService < Libra::Node::Service
      @servicename = "cgred"
    end

    class HttpdService < Libra::Node::Service
      @servicename = "httpd"
    end
  end
end
