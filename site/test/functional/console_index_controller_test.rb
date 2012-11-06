require File.expand_path('../../test_helper', __FILE__)

inline_test(File.expand_path(__FILE__))

class ConsoleIndexControllerTest < ActionController::TestCase
  test 'should contain status page url' do
    with_configured_user
    get :help
    assert_select "script", :minimum => 1 do |elements|
      assert elements.any?{ |e| (e['src'] || "").ends_with?('/status.js?id=outage') }
    end
  end
end
