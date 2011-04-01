#!/usr/bin/ruby
require 'test/unit'
require 'libra/node'


class TestSoftwarePackages < Test::Unit::TestCase
  
  def setup
    @pkglist = ['kernel', 'nosuchpackage', 'ruby']
  end

  def testConstructor
    pkglist0 = Libra::Node::SoftwarePackages.new @pkglist
    pkglist0.check
    #puts pkglist0
  end

  def testToXml
    pkglist0 = Libra::Node::SoftwarePackages.new @pkglist
    pkglist0.check
    #puts pkglist0.to_xml
  end

  def testToJson
    pkglist0 = Libra::Node::SoftwarePackages.new @pkglist
    pkglist0.check
    #puts pkglist0.to_json
  end

  def testParseJson
    pkglist0 = Libra::Node::SoftwarePackages.new @pkglist
    pkglist0.check
  end

end
