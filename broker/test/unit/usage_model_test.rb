require 'test_helper'

class UsageModelTest < ActiveSupport::TestCase
  def setup
    super
  end

  test "create and find usage event" do
    orig = usage
    ue = Usage.new
    ue.construct(orig.gear_uuid, orig.gear_type,
                 orig.action, orig.created_at)
    ue.save!
    ue = Usage.find(orig.uuid)
    ue.updated_at = nil
    assert_equal(orig, ue)
  end

  test "delete usage event" do
    ue = usage
    ue.save!
    ue = Usage.find(ue.uuid)
    assert(ue != nil)
    Usage.delete(ue.uuid)
    ue = Usage.find(ue.uuid)
    assert_equal(nil, ue)
  end
  
  test "find all usage events" do
    ues = Usage.find_all
    ues.each do |ue|
      ue.delete
    end
    (1..2).each do |i|
      ue = usage
      ue.save!
    end
    ues = Usage.find_all
    assert(ues.length == 2)
  end
  
  test "find usage by gear uuid" do
    ue = usage
    ue.save!
    ue = Usage.find_by_gear_uuid(ue.gear_uuid)
    assert(ue != nil)
  end

  def usage
    uuid = "usage#{gen_uuid}"
    obj = Usage.new
    obj.uuid = uuid
    obj._id = uuid
    obj.gear_uuid = uuid
    obj.gear_type = 'small'
    obj.action = 'create'
    obj.created_at = Time.now
    obj.updated_at = nil
    obj
  end
end
