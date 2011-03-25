#/usr/bin/ruby

require 'test/unit'
require 'libra/node'


class TestStatus < Test::Unit::TestCase
  
  def setup
    @s0 = Libra::Node::Status.new
    #@s1 = Libra::Node::Status.new [:all]
  end

  def testConstructor
    #s0 = Libra::Node::Status.new
  end


  def testPackages
    Libra::Node::Status.package_list = ['rpm', 'missingpackage']

    s0 = Libra::Node::Status.new [:packages]

    # check the missing package
    assert_nil(s0.packages['missingpackage'])

    # make these better, loop over available elements
    assert(s0.packages['rpm'])
    assert(s0.packages['rpm'][:version])
    assert(s0.packages['rpm'][:release])
  end

  def testSELinux
    s0 = Libra::Node::Status.new
    assert_nil(s0.selinux)

    s1 = Libra::Node::Status.new(checks=[:selinux])
    assert_equal("Disabled", s1.selinux)

    # force "Permissive"

    # force "Enforcing"
  end

  def testText
    s0 = Libra::Node::Status.new [:all]
    puts "\n-- Start testText --"
    puts s0.to_s
    puts "-- End testText --"

    
  end

  # check the elements of typical service
  def testService
    s0 = Libra::Node::Service.new
    assert_nil(s0.installed)
    assert_nil(s0.enabled)
    assert_nil(s0.running)
    assert_nil(s0.message)
    s1 = Libra::Node::Service.new :name => "ntpd"
  end

  def testServiceToString
    s0 = Libra::Node::Service.new
    assert_equal("Service noname: unknown", s0.to_s)
    s0.check
    assert_equal("Service noname: is not installed", s0.to_s)
    s0 = Libra::Node::Service.new :name => "ntpd"
  end

  def testServiceToXml
    s0 = Libra::Node::Service.new
    assert_equal("<service name=\"noname\">unknown</service>", s0.to_xml)
    s0.check
    assert_equal("<service name=\"noname\">not installed</service>", s0.to_xml)
    s1 = Libra::Node::Service.new :name => "ntpd"
    assert_equal("<service name=\"ntpd\">unknown</service>", s1.to_xml)
    s1.check
    assert_equal("<service name=\"ntpd\">unknown</service>", s1.to_xml)
  end
end
