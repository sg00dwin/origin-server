#!/usr/bin/ruby

require 'test/unit'
require 'libra/node'

class TestTrafficControl < Test::Unit::TestCase
  
  def setup
    @sample = {
      "qdisc" => {
        "type" => "htb",
        "classid" => "1:",
        "parent" => "root",
        "refcnt" => 0,
        "r2q" => 10,
        "default" => 0,
        "direct_packets_stat" => 0
      },

      "rootclass" => {
        "qdisc" => "htb",
        "classid" => "1:1",
        "parent" => "root",
        "prio" => nil,
        "rate" => "8000mb",
        "ceil" => "8000Mbit",
        "burst" => "0b",
        "cburst" => "0b"
      },

      "childclasses" => {
        "1:1f4" => {
        "qdisc" => "htb",
        "classid" => "1:1f4",
        "parent" => "1:1",
        "prio" => 0,
        "rate" => "2000kb",
        "ceil" => "20000kbit",
        "burst" => "1600b",
        "cburst" => "1600b"
        },
        
        "1:1f5" => {
        "qdisc" => "htb",
        "classid" => "1:1f5",
        "parent" => "1:1",
        "prio" => 0,
        "rate" => "2000kb",
        "ceil" => "20000kbit",
        "burst" => "1600b",
        "cburst" => "1600b"
        },
        
        "1:1f6" => {
        "qdisc" => "htb",
        "classid" => "1:1f6",
        "parent" => "1:1",
        "prio" => 0,
        "rate" => "2000kb",
        "ceil" => "20000kbit",
        "burst" => "1600b",
        "cburst" => "1600b"
        },
        
        "1:1f7" => {
        "qdisc" => "htb",
        "classid" => "1:1f7",
        "parent" => "1:1",
        "prio" => 0,
        "rate" => "2000kb",
        "ceil" => "20000kbit",
        "burst" => "1600b",
        "cburst" => "1600b"
        },
        
        "1:1f8" => {
        "qdisc" => "htb",
        "classid" => "1:1f8",
        "parent" => "1:1",
        "prio" => 0,
        "rate" => "2000kb",
        "ceil" => "20000kbit",
        "burst" => "1600b",
        "cburst" => "1600b"
        },
        
      }
    }

    @small = {
      "qdisc" => {
        "type" => "htb",
        "classid" => "1:",
        "parent" => "root",
        "refcnt" => 0,
        "r2q" => 10,
        "default" => 0,
        "direct_packets_stat" => 0
      },

      "rootclass" => {
        "qdisc" => "htb",
        "classid" => "1:1",
        "parent" => "root",
        "prio" => nil,
        "rate" => "8000mb",
        "ceil" => "8000Mbit",
        "burst" => "0b",
        "cburst" => "0b"
      },

      "childclasses" => {
        "1:1f4" => {
        "qdisc" => "htb",
        "classid" => "1:1f4",
        "parent" => "1:1",
        "prio" => 0,
        "rate" => "2000kb",
        "ceil" => "20000kbit",
        "burst" => "1600b",
        "cburst" => "1600b"
        },
        
      }
    }
    @pfifo_fast = {
      "qdisc" => {
        "type" => "pfifo_fast",
        "classid" => "0:",
        "parent" => "root",
        "refcount" => 0,
        "bands" => 3,
        "priomap" => [1, 2, 2, 2, 1, 2, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1]
      }
    }
  end

  def testConstructor
    tc0 = Libra::Node::TrafficControl.new
    tc0.check
    #puts "\n" + tc0.to_s
    #p tc0
    tc0.init(@sample)
    #p tc0
  end

  def testToString
    tc0 = Libra::Node::TrafficControl.new
    tc0.init(@sample)
    #puts tc0
  end

  def testToXml
    tc0 = Libra::Node::TrafficControl.new
    tc0.init(@sample)
    #puts tc0.to_xml
  end

  def testToJson
    tc0 = Libra::Node::TrafficControl.new
    tc0.init(@sample)
    #puts tc0.to_json
  end

  def testParseJson
    tc0 = Libra::Node::TrafficControl.new
    tc0.init(@small)
    #p tc0
    json0 = tc0.to_json
    tc1 = JSON.parse(json0)
    #p tc1
    #assert_equal(json0, tc1.to_json)
  end

end
