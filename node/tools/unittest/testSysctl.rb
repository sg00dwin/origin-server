#!/usr/bin/ruby

require 'test/unit'
require 'libra/node'


class TestSysCtl < Test::Unit::TestCase

  def testSysCtlAll
    sc0 = Libra::Node::Sysctl.new
    sc0.check
    #puts sc0
  end

  def testSysCtlSingle
    # kernel.sem = 250	32000	32	128
    sc0 = Libra::Node::Sysctl.new ["kernel.sem", 
                                   "kernel.random.write_wakeup_threshold"]
    sc0.check
    #puts sc0
  end

  def testSysCtlUnknown
    sc0 = Libra::Node::Sysctl.new ["kernel.sem", 
                                   "busted"]
    sc0.check
    #puts sc0
  end

  def testSysctlXml
    sc0 = Libra::Node::Sysctl.new ["kernel.sem", 
                                   "busted"]
    sc0.check
    #puts sc0.to_xml

  end

  def testSysctlToXml
    sc0 = Libra::Node::Sysctl.new ["kernel.sem", 
                                   "busted"]
    sc0.check
    #puts sc0.to_xml
  end

  def testSysctlToJson
    sc0 = Libra::Node::Sysctl.new ["kernel.sem", 
                                   "busted"]
    sc0.check
    #puts sc0.to_json
  end

  def testSysctlParseJson
    sc0 = Libra::Node::Sysctl.new ["kernel.sem", 
                                   "busted"]
    sc0.check
    json0 = sc0.to_json
    sc1 = JSON.parse(json0)
    assert_equal(sc0.keys.sort, sc1.keys.sort)

  end


end
