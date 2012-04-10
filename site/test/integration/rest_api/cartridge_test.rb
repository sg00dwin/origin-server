require File.expand_path('../../../test_helper', __FILE__)

class RestApiCartridgeTest < ActiveSupport::TestCase

  def setup
    with_simple_unique_user
  end
  def teardown
    cleanup_domain
  end
end
