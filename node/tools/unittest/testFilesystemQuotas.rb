#!/usr/bin/ruby
require 'test/unit'
require 'libra/node'


class TestFilesystemQuotas < Test::Unit::TestCase

  def setup 
    @sample = {
      "filesystems" =>
      [
       {"name" => '/', "device" => "/dev/sda0", "status" => "on"},
       {"name" => '/foo', "device" => "/dev/sda1", "status" => "off"}
      ]
    }
  end

  def testQuotaConstructor
    q0 = Libra::Node::FilesystemQuotas.new
    q0.check
    #puts q0

  end

  def testQuotaToString
    q0 = Libra::Node::FilesystemQuotas.new
    q0.init(@sample)
    #puts q0
  end

  def testQuotaToXml
    q0 = Libra::Node::FilesystemQuotas.new
    q0.init(@sample)
    #puts q0.to_xml
  end


  def testQuotaToJson
    q0 = Libra::Node::FilesystemQuotas.new
    q0.init(@sample)
    #puts q0.to_json
  end

  def testQuotaParseJson
    q0 = Libra::Node::FilesystemQuotas.new
    q0.init(@sample)
    json0 = q0.to_json
    q1 = JSON.parse(json0)
    json1 = q1.to_json

    assert_equal(json0, json1)
  end
end
