#/usr/bin/ruby

require 'test/unit'
require 'libra/node'


class TestService < Test::Unit::TestCase
  
  # check the elements of typical service
  def testService
    s0 = Libra::Node::Service.new
    assert_nil(s0.installed)
    assert_nil(s0.enabled)
    assert_nil(s0.running)
    assert_nil(s0.message)
    s1 = Libra::Node::Service.new :servicename => "ntpd"
  end

  def testServiceToString
    s0 = Libra::Node::Service.new
    assert_equal("Service noname: unknown\n", s0.to_s)
    s0.check
    assert_equal("Service noname: is not installed\n", s0.to_s)
    s1 = Libra::Node::Service.new :servicename => "ntpd"
    assert_equal("Service ntpd: unknown\n", s1.to_s)
    s1.check
    #assert_equal("Service ntpd: is not installed\n", s1.to_s)
  end

  def testServiceToXml
    s0 = Libra::Node::Service.new
    assert_equal("<service name=\"noname\">unknown</service>", s0.to_xml)
    s0.check
    assert_equal("<service name=\"noname\">not installed</service>", s0.to_xml)
    s1 = Libra::Node::Service.new :servicename => "ntpd"
    assert_equal("<service name=\"ntpd\">unknown</service>", s1.to_xml)
    s1.check
    #assert_equal("<service name=\"ntpd\">unknown</service>", s1.to_xml)
  end

  def testServiceToJson
    s0 = Libra::Node::Service.new
    assert_equal("{\"name\":\"noname\",\"json_class\":\"Libra::Node::Service\"}", s0.to_json)
    s0.check
    assert_equal("{\"name\":\"noname\",\"json_class\":\"Libra::Node::Service\",\"installed\":false}", s0.to_json)
    s1 = Libra::Node::Service.new :servicename => "ntpd"
    assert_equal("{\"name\":\"ntpd\",\"json_class\":\"Libra::Node::Service\"}", s1.to_json)
    s1.check
    assert_match(/\{"name":"ntpd","running":true,"json_class":"Libra::Node::Service","enabled":\["off","off","on","on","on","on","off"\],"installed":true,"message":"ntpd \(pid /, s1.to_json)
  end

  def testServiceFromJson
    s0 = Libra::Node::Service.new :servicename => "ntpd"
    s0.check
    json0 = s0.to_json

    s1 = JSON.parse(json0)

    json1 = s1.to_json

    assert_equal(json0, json1)
    #p json1
    #p s1.to_xml
  end
end
