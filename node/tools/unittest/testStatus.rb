#!/usr/bin/ruby

require 'test/unit'
require 'libra/node'


class TestStatus < Test::Unit::TestCase
  
  def setup
    #@s0 = Libra::Node::Status.new
    #@s1 = Libra::Node::Status.new :all
  end

  def testConstructor
    s0 = Libra::Node::Status.new
    s1 = Libra::Node::Status.new :all
  end

  def testHostInfo
    s0 = Libra::Node::Status.new :all
    #puts "\n----\n\n"
    #puts s0.to_s
    #puts "\n----\n"
    #puts "hostinfo = #{s0.hostinfo}"
  end

  def testToXml
    s0 = Libra::Node::Status.new :all
    #puts s0.to_xml
    #puts s0.ntpd.to_xml
  end

  def testToJson
    s0 = Libra::Node::Status.new :all
    #puts s0.to_json
  end
end
