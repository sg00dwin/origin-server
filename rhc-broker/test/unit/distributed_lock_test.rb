ENV["TEST_NAME"] = "unit_distributed_loct_test"
require 'test_helper'

class DistributedLockTest < ActiveSupport::TestCase
  def setup
    super
  end

  test "distributed lock" do
    dl = DistributedLock
    type = gen_uuid
    assert(dl.obtain_lock(type, "1"))
    assert(!dl.obtain_lock(type, "1"))
    assert(!dl.obtain_lock(type, "2"))
    dl.release_lock(type, "1")
    assert(dl.obtain_lock(type, "2"))
    assert(dl.obtain_lock(type, "2", true))
    dl.release_lock(type)
    assert(dl.obtain_lock(type, "2"))
    dl.release_lock(type)
  end
end
