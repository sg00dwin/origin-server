#!/usr/bin/ruby

require 'test/unit'
require 'libra/node'


class TestSelinux < Test::Unit::TestCase

  def testSelinux
    se0 = Libra::Node::Selinux.new
    se0.check
    #puts se0
  end

  def testSelinuxToXml
    se0 = Libra::Node::Selinux.new
    se0.check
    #puts se0.to_xml
  end

  def testSelinuxToJson
    se0 = Libra::Node::Selinux.new
    se0.check
    #puts se0.to_json
  end

  def testSelinuxParseJason
    se0 = Libra::Node::Selinux.new
    se0.check
    se1 = JSON.parse(se0.to_json)
    assert_equal(se0.enabled, se1.enabled)
    assert_equal(se0.enforcing, se1.enforcing)
  end
  
end
