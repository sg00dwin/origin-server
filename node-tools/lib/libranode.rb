#
# Classes and methods useful for operation and observation of a 
# Red Hat Libra Node
#

require 'rubygems'
require 'builder'
require 'json'

#
# Open the password file, find all the entries with the marker in them
# and create a data structure with the usernames of all matching accounts
#

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
    xml = Builder::XmlMarkup.new( :indent => 2 )
    xml.account(:username => @username)
  end
  
  def to_json
    JSON.pretty_generate({"username" => @username})
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
    xml = Builder::XmlMarkup.new( :indent => 2 )
    xml.application(:appname => @appname)
  end
  
  def to_json
    JSON.pretty_generate({"appname" => @appname})
  end

end
