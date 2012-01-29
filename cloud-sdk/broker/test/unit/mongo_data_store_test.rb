require 'test_helper'

class MongoDataStoreTest < ActiveSupport::TestCase
  include Cloud::Sdk

  def setup
    super
  end

  test "create and find cloud user" do
    ds = MongoDataStore.new
    orig_cu = cloud_user
    user_id = orig_cu["rhlogin"]
    ds.create("CloudUser", user_id, nil, orig_cu)
    cu = ds.find("CloudUser", user_id, nil)
    assert_equal(orig_cu, cu)
  end

  def cloud_user
    uuid = gen_uuid
    cloud_user = {
      "rhlogin" => "user_id#{uuid}",
      "uuid" => uuid,
      "system_ssh_keys" => {},
      "env_vars" => {},
      "ssh_keys" => {},
      "namespace" => "namespace#{uuid}",
      "max_gears" => 2,
      "consumed_gears" => 0
    }
    cloud_user
  end

end
