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

    # survey the status of the Libra services on a node
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

    # calling examples
    # Node.new - 
    # Node.new(json => "")
    # Node.new(xml => "")
    # Node.new(survey => :all)
    # Node.new(survey => [:selinux, :qpid, ...])

    class Status

      attr        :hostname
      attr_writer :packages, :selinux, :qpid

      #attr_writer :packages :selinux, :qpid, :mcollective, 
      #attr_writer :cgroups, :tc, :quota, :httpd

      @@package_list = ['qpid-cpp-server', 'qpid-cpp-client', 'ruby-qmf',
                        'mcollective', 'mcollective-client',
                        'li-node',
                        'li-cartridge-php-5.3.2', 
                        'li-rack-1.1.0', 
                        'li-wsgi-3.2.1']

      @@selinux_booleans = {}
      @@sysctl_values = {}

      def self.package_list=(packages)
        @@package_list = packages
      end

      @@selinux_command = "getenforce"
      def self.selinux_command(cmd)
        @@selinux_command = cmd
      end

      @@checks = [:packages, :selinux, :qpid, :mcollective, :cgroups, :tc,
                  :quota, :httpd, :applications]

      def initialize(checks=[])
        @hostname = `hostname`.strip
        @syscfg = nil
        @packages = nil
        @selinux = nil
        #@qpid = QpidService.new
        #@mcollective = McollectiveService.new
        #@cgconfig = CgconfigService.new
        #@cgred = CgRulesService.new
        @tc = nil
        @quota = nil
        @httpd = nil
        @applications = nil

        # check of args[0] is a Hash and contains one element: json
        checks = @@checks if checks[0] == :all
        checks.each do |check|
          case check
          when :packages then
            packages(check=true)
          when :selinux then
            selinux(check=true)
          #when :qpid then
          #  qpid(check=true)
          #when :cgconfig then
          #  cgconfig(check=true)
          end
        end
      end

      def to_s
        headerstring = " Libra Node Status for host #{@hostname} "
        indent = (80 - headerstring.length) / 2
        out = "-" * indent + headerstring + "-" * indent + "\n"
        # selinux
        if @selinux
          out += "SELinux: #{@selinux}\n"
        end
        
        # packages
        if @packages
          out += "\nPackages:\n"
          packages.keys.sort.each do |pkgname|
            out += "  #{pkgname} "
            if packages[pkgname] then
              out += "#{@packages[pkgname][:version]} #{@packages[pkgname][:release]}\n"
            else
              out += "not installed\n"
            end
          end
        end

        # qpid
        if @qpid
          out += "\nQPID: #{@qpid}\n"
        end
        # mcollective
        # cgroup service
        # cgred service
        # httpd service

        # libra cgroups
        # libra tc
        # quotas

        out += "\n" + "-" * 80
      end
      
      def to_json

      end

      def self.json_create(o)
        new(*o)
        # add status
      end

      def to_xml

      end

      #
      # Check the set of required packages
      # 
      def packages(check=false)
        return @packages if not check
        @packages = {}
        @@package_list.each do |pkgname|
          pkgspec = `rpm -q --qf '%{VERSION} %{RELEASE}' #{pkgname}`.strip
          if /is not installed$/ =~ pkgspec then
            @packages[pkgname] = nil
          else
            pkgspec = pkgspec.split
            @packages[pkgname] = {:version => pkgspec[0], :release => pkgspec[1]}
          end
        end
      end

      #
      # Check or report SELinux status
      #
      def selinux(check=false)
        return @selinux if not check
        @selinux = `getenforce`.strip 
      end

      def qpid(check=false)
        # check for present, enabled, running
        return @qpid if not check
        @qpid = `service qpid status 2>&1`
      end

      def cgconfig(check=false)
        return @cgconfig if not check
        @cgconfig = `service cgconfig status 2>&1`
      end

      def cgred(check=false)
        return @cgred if not check
        @cgred = `service cgconfig status 2>&1`
      end
    end

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
    

    #
    # Model a generic service
    # 
    class Service

      class << self
        attr_accessor :servicename, :stop_pattern, :running_pattern
      end

      #
      # Service.new
      # Service.new [:check]
      #
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

    class CgRulesService < Libra::Node::Service
      @servicename = "cgred"
    end


  end
end
