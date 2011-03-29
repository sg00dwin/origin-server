#/usr/bin/ruby

require 'test/unit'
require 'libra/node'


class TestSysCtl < Test::Unit::TestCase

  def testSysCtlAll
    sc0 = Libra::Node::Sysctl.new :all
    sc0.check
    #puts sc0
  end

  def testSysCtlSingle
    # kernel.sem = 250	32000	32	128
    sc0 = Libra::Node::Sysctl.new ["kernel.sem", 
                                   "kernel.random.write_wakeup_threshold"]
    sc0.check
    puts sc0
  end

  def testSysCtlUnknown
    sc0 = Libra::Node::Sysctl.new ["kernel.sem", 
                                   "busted"]
    sc0.check
    puts sc0
  end
end
