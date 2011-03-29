#/usr/bin/ruby

require 'test/unit'
require 'libra/node'


class TestSysCtl < Test::Unit::TestCase

  def testSysCtlAll
    sc0 = Libra::Node::Sysctl.new :all
    sc0.check
    puts sc0
  end
end
