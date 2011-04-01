#!/usr/bin/ruby

require 'test/unit'
require 'libra/node'


class TestHostInfo < Test::Unit::TestCase
  
  class << self
    attr_reader :hostname
  end

  @hostname = `hostname`.strip

  def setup
    @testinfo = {
      "hostname" => "myhost",
      "uptime" => "00:00:00"
    }
  end

  def testConstructor
    h0 = Libra::Node::HostInfo.new

    assert_nil(h0.hostname)
    assert_nil(h0.uptime)
  end

  def testCheck
    h0 = Libra::Node::HostInfo.new true
    assert_equal(self.class.hostname, h0.hostname)
    assert(h0.uptime)
  end

  def testToString
    teststring = "-- HostInfo --\n  Hostname: myhost\n  Uptime: 00:00:00\n"
    h0 = Libra::Node::HostInfo.new
    h0.init @testinfo
    assert_equal(teststring, h0.to_s)
  end

  def testToXml
    testxml = '<hostinfo hostname="myhost" uptime="00:00:00"/>'
    h0 = Libra::Node::HostInfo.new
    h0.init @testinfo
    h1 = Nokogiri::XML.parse(h0.to_xml)
    #assert_equal(testxml, h0.to_xml)
    assert_equal("myhost", h1.root['hostname'])
  end

  def testToJson
    testjson0 = "{\"json_class\":\"Libra::Node::HostInfo\"}"
    testjson1 = "{\"json_class\":\"Libra::Node::HostInfo\",\"uptime\":\"00:00:00\",\"hostname\":\"myhost\"}"
    h0 = Libra::Node::HostInfo.new
    assert_equal(testjson0, h0.to_json)
    h0.init @testinfo
    assert_equal(testjson1, h0.to_json)
  end

  def testParseJson
    h0 = Libra::Node::HostInfo.new
    h0.init @testinfo
    json0 = h0.to_json
    h1 = JSON.parse(json0)
    assert_equal(h0.hostname, h1.hostname)
    assert_equal(h0.uptime, h1.uptime)    
  end

end
