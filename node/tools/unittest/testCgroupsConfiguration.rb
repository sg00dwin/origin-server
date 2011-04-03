#!/usr/bin/ruby

require 'test/unit'
require 'libra/node'

class TestLibraCgroups < Test::Unit::TestCase

  def setup
    @mounts = {"/cgroup/all" => ["cpu", "cpuacct", "freezer", "memory", "net_cls"]}
  end

  def testConstructor
    lc0 = Libra::Node::CgroupsConfiguration.new
  end

  def testGetMounts
    lc0 = Libra::Node::CgroupsConfiguration.new
    cfg = lc0.get_mounts
    assert_equal({"/cgroup/ns"=>["ns"],
                   "/cgroup/cpuset"=>[],
                   "/cgroup/freezer"=>["freezer"],
                   "/cgroup/devices"=>["devices"],
                   "/cgroup/cpuacct"=>["cpuacct"],
                   "/cgroup/net_cls"=>["net_cls"],
                   "/cgroup/blkio"=>["blkio"],
                   "/cgroup/cpu"=>["cpu"],
                   "/cgroup/memory"=>["memory"]},
                 cfg)

 end

  def testToString
    lc0 = Libra::Node::CgroupsConfiguration.new
    lc0.init({"mounts" => @mounts})
    #puts lc0.to_s
  end

  def testToXml
    lc0 = Libra::Node::CgroupsConfiguration.new
    lc0.init({"mounts" => @mounts})
    #puts lc0.to_xml
  end

  def testToJson
    lc0 = Libra::Node::CgroupsConfiguration.new
    lc0.init({"mounts" => @mounts})
    #puts lc0.to_json
  end

  def testParseJson
    lc0 = Libra::Node::CgroupsConfiguration.new
    lc0.init({"mounts" => @mounts})
    json0 = lc0.to_json
    lc1 = JSON.parse(json0)
    assert_equal(json0, lc1.to_json)
  end
end
