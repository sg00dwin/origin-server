#!/usr/bin/ruby
require 'test/unit'
require 'libra/node'


class TestFilesystemQuotas < Test::Unit::TestCase

  def setup 
    @sample = {
      :filesystems =>
      [
       {:name => '/', :device => "/dev/sda0", :status => "on"},
       {:name => '/foo', :device => "/dev/sda1", :status => "off"}
      ]
    }
  end

  def testQuotaConstructor
    q0 = Libra::Node::FilesystemQuotas.new
    q0.check
    #puts q0

  end

  def testQuotaToString
    q0 = Libra::Node::FilesystemQuotas.new
    q0.init(@sample)
    puts q0
  end

  def testQuotaToXml
    q0 = Libra::Node::FilesystemQuotas.new
    q0.init(@sample)
    puts q0.to_xml
  end


  def testQuotaToJson
    q0 = Libra::Node::FilesystemQuotas.new
    q0.init(@sample)
    puts q0.to_json
  end
end
