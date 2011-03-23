#/usr/bin/ruby

require 'test/unit'
require 'libra/node'

GuestAccount.passwd_file = File.dirname(__FILE__) + "/data/passwd"

class LibraListAccountsTest < Test::Unit::TestCase

  def testAccountList
    alist = GuestAccount.accounts
    assert_equal(400, alist.length)
  end
end

class LibraAccountTest < Test::Unit::TestCase
  
  def setup
    @username = "aabbccddeeff00112233445566778000"
    @a0 = GuestAccount.new(@username)
  end

  def testInitialize
    assert_equal(@username, @a0.username)
  end

  def testText
    assert_equal(@username, @a0.to_s)
  end

  def testXml
    assert_equal("<account username=\"%s\"/>" % @username, @a0.to_xml)
  end

  def testJson
    assert_equal("{\n  \"username\": \"%s\"\n}" % @username, @a0.to_json)
  end

  def testHomedir
    assert_equal("/var/lib/libra/%s" % @username, @a0.homedir)
    assert_equal("/var/lib/libra/%s" % @username, @a0.homedir)
  end

  def testAppnames
    homedir = File.dirname( __FILE__ ) + "/data/home/#{@a0.username}"
    applist = ["bar", "foo", "gronk"]
    assert_equal(applist, @a0.appnames(homedir))
  end
end

class LibraApplicationTest < Test::Unit::TestCase

  def setup
    @username = ""
    @appname = "myapp0"
    @acct = GuestAccount.new(@username)
    @apptype = "php-5.3.2"
    @app0 = Application.new(@appname, nil, @apptype)
    #@app1 = Application.new(@appname, @acct)
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
    assert_equal("{\n  \"appname\": \"%s\"\n}" % @appname, @app0.to_json)
  end
end
