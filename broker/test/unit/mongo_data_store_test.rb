require 'test_helper'

class MongoDataStoreTest < ActiveSupport::TestCase
  include Express::Broker

  def setup
    super
  end

  test "create and find district" do
    ds = MongoDataStore.new
    orig_d = district
    uuid = orig_d["uuid"]
    ds.save_district(uuid, orig_d)
    d = ds.find_district(uuid)
    assert_equal(orig_d, d)
  end
  
  test "find all districts" do
    ds = MongoDataStore.new
    (1..2).each do |i|
      d = district
      ds.save_district(d["uuid"], d)
    end
    data = ds.find_all_districts
    assert(data.length >= 2)
  end
  
  test "delete district" do
    ds = MongoDataStore.new
    d = district
    uuid = d["uuid"]
    ds.save_district(uuid, d)
    d = ds.find_district(uuid)
    assert_not_nil(d)
    d = ds.delete_district(uuid)
    d = ds.find_district(uuid)
    assert_equal(nil, d)
  end
  
  test "reserve district uid" do
    ds = MongoDataStore.new
    d = district
    uuid = d["uuid"]
    orig_available_uids = d["available_uids"]
    orig_available_capacity = d["available_capacity"]
    ds.save_district(uuid, d)
    uid = ds.reserve_district_uid(uuid)
    d = ds.find_district(uuid)
    assert_equal(orig_available_uids.length - 1, d["available_uids"].length)
    assert_equal(orig_available_capacity - 1 , d["available_capacity"])
    assert(!d["available_uids"].include?(uid))
    
    (1..d["available_capacity"]).each do |i| 
      uid = ds.reserve_district_uid(uuid)
    end
    
    caught_exception = false
    begin
      uid = ds.reserve_district_uid(uuid)
    rescue Exception => e
      caught_exception = true
    end
    assert(caught_exception)
    
    ds.unreserve_district_uid(uuid, 1)
    d = ds.find_district(uuid)
    assert_equal(1, d["available_uids"].length)
    assert_equal(1 , d["available_capacity"])
    assert(d["available_uids"].include?(1))
      
    ds.unreserve_district_uid(uuid, 1)
    d = ds.find_district(uuid)
    assert_equal(1, d["available_uids"].length)
    assert_equal(1 , d["available_capacity"])
    assert(d["available_uids"].include?(1))
  end
  
  test "inc district externally reserved uids size" do
    ds = MongoDataStore.new
    d = district
    uuid = d["uuid"]
    orig_externally_reserved_uids_size = d["externally_reserved_uids_size"]
    ds.save_district(uuid, d)
    ds.inc_district_externally_reserved_uids_size(uuid)
    d = ds.find_district(uuid)
    assert_equal(orig_externally_reserved_uids_size + 1, d["externally_reserved_uids_size"])
  end
  
  test "district capacity" do
    ds = MongoDataStore.new
    d = district
    uuid = d["uuid"]
    orig_available_uids = d["available_uids"]
    orig_available_capacity = d["available_capacity"]
    orig_max_capacity = d["max_capacity"]
    ds.save_district(uuid, d)
    additional_uids = [11,12]
    ds.add_district_uids(uuid, additional_uids)
    d = ds.find_district(uuid)
    assert_equal(orig_available_uids.length + 2, d["available_uids"].length)
    assert_equal(orig_available_capacity + 2, d["available_capacity"])
    assert_equal(orig_max_capacity + 2, d["max_capacity"])
    ds.remove_district_uids(uuid, additional_uids)
    d = ds.find_district(uuid)
    assert_equal(orig_available_uids.length, d["available_uids"].length)
    assert_equal(orig_available_capacity, d["available_capacity"])
    assert_equal(orig_max_capacity, d["max_capacity"])
  end
  
  test "district nodes" do
    ds = MongoDataStore.new
    d = district
    uuid = d["uuid"]
    ds.save_district(uuid, d)
    hostname = "node#{uuid}.rhcloud.com"
    ds.add_district_node(uuid, hostname)
    d = ds.find_district(uuid)
    assert(d["server_identities"][hostname]["active"])
      
    d = ds.find_available_district
    assert_not_nil(d)
    assert(d["available_capacity"] > 0)
      
    d = ds.find_district_with_node(hostname)
    assert_equal(uuid, d["uuid"])
      
    ds.remove_district_node(uuid, hostname)
    d = ds.find_district(uuid)
    assert(d["server_identities"][hostname]["active"])
        
    ds.deactivate_district_node(uuid, hostname)
    d = ds.find_district(uuid)
    assert(!d["server_identities"][hostname]["active"])
      
    ds.activate_district_node(uuid, hostname)
    d = ds.find_district(uuid)
    assert(d["server_identities"][hostname]["active"])
      
    ds.deactivate_district_node(uuid, hostname)
    d = ds.find_district(uuid)
    assert(!d["server_identities"][hostname]["active"])
 
    ds.remove_district_node(uuid, hostname)
    d = ds.find_district(uuid)  
    assert(!d["server_identities"][hostname])
      
    ds.add_district_node(uuid, hostname)
    orig_d = ds.find_district(uuid)
    assert(orig_d["server_identities"][hostname]["active"])

    (1..10).each do |i|
      hostname_i = "node" + i.to_s + "#{uuid}.rhcloud.com"
      ds.add_district_node(uuid, hostname_i)
      d = ds.find_district(uuid)
      assert(d["server_identities"][hostname_i]["active"])
      assert(d["server_identities"][hostname]["active"])
    end
    
    d = ds.find_district_with_node(hostname)
    assert_equal(uuid, d["uuid"])
    
    (1..10).each do |i|
      hostname_i = "node" + i.to_s + "#{uuid}.rhcloud.com"
      ds.deactivate_district_node(uuid, hostname_i)
      d = ds.find_district(uuid)
      assert(!d["server_identities"][hostname_i]["active"])
      assert(d["server_identities"][hostname]["active"])
    end
    
    (1..10).each do |i|
      hostname_i = "node" + i.to_s + "#{uuid}.rhcloud.com"
      ds.remove_district_node(uuid, hostname_i)
      d = ds.find_district(uuid)
      assert(!d["server_identities"][hostname_i])
      assert(d["server_identities"][hostname]["active"])
    end
    
    assert_equal(orig_d, d)
    
    ds.deactivate_district_node(uuid, hostname)
    d = ds.find_district(uuid)
    assert(!d["server_identities"][hostname]["active"])
    
    ds.remove_district_node(uuid, hostname)
    d = ds.find_district(uuid)
    assert(!d["server_identities"][hostname])
    
    ds.delete_district(uuid)
    d = ds.find_district(uuid)
    assert_equal(nil, d)
  end
  
  test "distributed lock" do
    ds = MongoDataStore.new
    type = gen_uuid
    assert(ds.obtain_distributed_lock(type, "1"))
    assert(!ds.obtain_distributed_lock(type, "1"))
    assert(!ds.obtain_distributed_lock(type, "2"))
    ds.release_distributed_lock(type, "1")
    assert(ds.obtain_distributed_lock(type, "2"))
    assert(ds.obtain_distributed_lock(type, "2", true))
    ds.release_distributed_lock(type)
    assert(ds.obtain_distributed_lock(type, "2"))
  end

  def district
    uuid = gen_uuid
    district = {
      "server_identities" => {}, 
      "active_server_identities_size" => 0, 
      "uuid" => uuid,
      "creation_time" => DateTime::now().strftime,
      "available_capacity" => 10,
      "available_uids" => [1,2,3,4,5,6,7,8,9],
      "max_uid" => 10,
      "max_capacity" => 10,
      "externally_reserved_uids_size" => 0,
      "node_profile" => 'small',
      "name" => "name#{uuid}"
    }
    district
  end
end
