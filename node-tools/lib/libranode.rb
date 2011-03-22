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
    File.open(@@passwd_file, "r") do |f|
      while line = f.gets do
        entry = line.split(":")
        return entry[5] if entry[0] == @username
      end
    end
  end

  # find the applications associated with this user
  def applications
    # get the user's home directory

    # find the git repositories

    # remove leading/trailing stuff

    # find the app type
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

  def initialize(appname, apptype=nil, account=nil)
    @appname = appname
    @apptype = apptype
    @account = account
  end

  
end
