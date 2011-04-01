#!/usr/bin/ruby

require 'test/unit'
require 'libra/node'

class TestLibraCgroups < Test::Unit::TestCase

  def setup
    
    # a config for parse testing
    @configfile = <<EOF
# an initial comment
# By default, mount all controllers to /cgroup/<controller>

mount {
#	cpuset	= /cgroup/all;
	cpu	= /cgroup/all;
	cpuacct	= /cgroup/all;
	memory	= /cgroup/all;
#	devices	= /cgroup/all;
	freezer	= /cgroup/all;
	net_cls	= /cgroup/all;
#	blkio	= /cgroup/all;
}
EOF

    #

  end
  def testConstructor
    lc0 = Libra::Node::CgroupsConfiguration.new
  end

  def testParseConfig
    lc0 = Libra::Node::CgroupsConfiguration.new
    cfg = lc0.parse_config(@configfile)
    assert_equal({"subsystems"=>
                   {"memory"=>{"mountpoint"=>"/cgroup/all"},
                     "freezer"=>{"mountpoint"=>"/cgroup/all"},
                     "cpuacct"=>{"mountpoint"=>"/cgroup/all"},
                     "net_cls"=>{"mountpoint"=>"/cgroup/all"},
                     "cpu"=>{"mountpoint"=>"/cgroup/all"}}}, cfg)
  end

  
end
