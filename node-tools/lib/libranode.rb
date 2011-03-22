#
# Classes and methods useful for operation and observation of a 
# Red Hat Libra Node
#

require 'rubygems'
require 'builder'
require 'json'

class GuestAccount
  
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


  def applications

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
