#/usr/bin/ruby

require 'test/unit'
require 'libra/node'

Libra::Node::GuestAccount.passwd_file = File.dirname(__FILE__) + "/data/etc/passwd"

class LibraApplicationTest < Test::Unit::TestCase

  def setup
    @username = ""
    @appname = "myapp0"
    @acct = Libra::Node::GuestAccount.new(@username)
    @apptype = "php-5.3.2"
    @app0 = Libra::Node::Application.new(@appname, nil, @apptype)
    #@app1 = Libra::Node::Application.new(@appname, @acct)
  end

  def testInitialize
    assert_equal(@appname, @app0.appname)
    assert_equal(@apptype, @app0.apptype)
    assert_nil(@app0.account)
  end

  def testText
    assert_equal(@appname, @app0.to_s)
  end

  def testXml
    assert_equal("<application appname=\"%s\"/>" % @appname, @app0.to_xml)
  end

  def testJson
    app0 = JSON.parse(@app0.to_json)
    assert_equal(@appname, app0.appname)
  end
end
