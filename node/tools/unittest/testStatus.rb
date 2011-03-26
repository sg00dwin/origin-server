#/usr/bin/ruby

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

  def

  def testHostInfo
    s0 = Libra::Node::Status.new :hostinfo
  end


end
