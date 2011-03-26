#/usr/bin/ruby

require 'test/unit'
require 'libra/node'

class TestDiskUsage < Test::Unit::TestCase

  def testDiskUsage
    d0 = Libra::Node::DiskUsage.new

    d0.check
  end

  def testToString
    d0 = Libra::Node::DiskUsage.new

    d0.check
    puts d0
  end
  
  def testToXml
    d0 = Libra::Node::DiskUsage.new

    d0.check
    puts d0.to_xml
  end

  def testToJson
    d0 = Libra::Node::DiskUsage.new

    d0.check
    puts d0.to_json
  end

  def testFromJson
    d0 = Libra::Node::DiskUsage.new

    d0.check
    puts d0.to_json

    d1 = JSON.parse(d0.to_json)
  end
end
