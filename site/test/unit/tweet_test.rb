require File.expand_path('../../test_helper', __FILE__)

class TweetTest < ActiveSupport::TestCase

  uses_http_mock
  setup{ Rails.cache.clear }
  setup{ ActiveResource::HttpMock.reset! }

end

