#!/usr/bin/ruby

require 'test/unit'
require 'libra/node'


class TestSelinuxBoolean < Test::Unit::TestCase

  def testSelinuxBooleanAll
    se0 = Libra::Node::SelinuxBoolean.new
    se0.check
    #puts sc0
    puts se0
  end

  def testSelinuxBooleanToXml
    se0 = Libra::Node::SelinuxBoolean.new
    se0.check
    puts sc0.to_xml
  end

  def testSelinuxBooleanToJson
    se0 = Libra::Node::SelinuxBoolean.new
    se0.check
    puts sc0.to_json
  end

  
end
