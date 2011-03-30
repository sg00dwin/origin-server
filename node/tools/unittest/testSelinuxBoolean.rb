#!/usr/bin/ruby

require 'test/unit'
require 'libra/node'


class TestSelinuxBoolean < Test::Unit::TestCase

  def testSelinuxBooleanAll
    se0 = Libra::Node::SelinuxBoolean.new
    se0.check
    #puts se0
  end

  def testSelinuxBooleanToXml
    se0 = Libra::Node::SelinuxBoolean.new
    se0.check
    #puts se0.to_xml

    se1 = Libra::Node::SelinuxBoolean.new 'httpd_can_network_relay'
    se1.check
    #puts se1.to_xml

  end

  def testSelinuxBooleanToJson
    se0 = Libra::Node::SelinuxBoolean.new
    se0.check
    #puts se0.to_json

    se1 = Libra::Node::SelinuxBoolean.new 'httpd_can_network_relay'
    se1.check
    #puts se1.to_json
  end

  
  
end
