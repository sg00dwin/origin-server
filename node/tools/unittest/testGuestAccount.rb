#/usr/bin/ruby

require 'test/unit'
require 'libra/node'

Libra::Node::GuestAccount.passwd_file = File.dirname(__FILE__) + "/data/etc/passwd"

class LibraListAccountsTest < Test::Unit::TestCase

  def testAccountList
    alist = Libra::Node::GuestAccount.accounts
    assert_equal(400, alist.length)
  end
end

class LibraAccountTest < Test::Unit::TestCase
  
  def setup
    @username = "aabbccddeeff00112233445566778000"
    @a0 = Libra::Node::GuestAccount.new(@username)
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
    a0 = JSON.parse(@a0.to_json)
    assert_equal(@username, a0.username)
  end

  def testHomedir
    assert_equal("/var/lib/libra/%s" % @username, @a0.homedir)
    assert_equal("/var/lib/libra/%s" % @username, @a0.homedir)
  end

  def testAppnames
    homedir = File.dirname( __FILE__ ) + "/data/var/lib/libra/#{@a0.username}"
    applist = ["bar", "foo", "gronk"]
    assert_equal(applist, @a0.appnames(homedir))
  end
end

