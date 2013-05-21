ENV["TEST_NAME"] = "usage_integration_billing_events_test"
require 'test_helper'
require 'mocha'

class BillingEventsTest < ActionDispatch::IntegrationTest
  BILLING_EVENTS_URL = "/billing/rest/events"
  def setup
    @unauthenticated_headers = {}
    @unauthenticated_headers["HTTP_ACCEPT"] = "application/json"
  end

  test "billing events failure" do
    request_via_redirect(:post, BILLING_EVENTS_URL, {}, @unauthenticated_headers)
    assert_response 401
  end
end
