#/usr/bin/ruby

require 'test/unit'
require 'libra/node'

class TestFilesystems < Test::Unit::TestCase

  def testFilesystems
    d0 = Libra::Node::Filesystems.new

    d0.check
  end

  def testToString
    d0 = Libra::Node::Filesystems.new

    d0.check
    #puts d0
  end
  
  def testToXml
    d0 = Libra::Node::Filesystems.new

    d0.check
    #puts d0.to_xml
  end

  def testToJson
    d0 = Libra::Node::Filesystems.new

    d0.check
    #puts d0.to_json
  end

  def testFromJson
    d0 = Libra::Node::Filesystems.new

    d0.check
    #puts d0.to_json

    d1 = JSON.parse(d0.to_json)
    assert_equal(d0.to_xml, d1.to_xml)
  end
end
