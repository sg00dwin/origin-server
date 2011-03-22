#/usr/bin/ruby

require 'test/unit'
require 'libranode'

class LibraAccountTest < Test::Unit::TestCase
  
  def setup
    @username = "aabbccddeeffgghhiijj01234567890ff"
    @a0 = GuestAccount.new("aabbccddeeffgghhiijj01234567890ff")
  end

  def testInitialize
    assert_equal(@username, @a0.username)
  end

  def testText
    assert_equal(@username, @a0.to_s)
  end

  def testXml
    assert_equal("<account username=\"%s\"/>\n" % @username, @a0.to_xml)
  end

  def testJson
    assert_equal("{\n  \"username\": \"%s\"\n}" % @username, @a0.to_json)
  end

end
