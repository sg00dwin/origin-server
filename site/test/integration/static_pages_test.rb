require File.expand_path('../../test_helper', __FILE__)

inline_test(File.expand_path(__FILE__))

class StaticPagesTest < ActionDispatch::IntegrationTest

  setup{ https! }

  def unexpected_regex
    /We appear to be having technical difficulties/
  end

  def internal_user
    {:rhlogin => 'test', :password => 'test'}
  end

  def controller_raises(exception)
    post '/login', internal_user
    ConsoleIndexController.any_instance.expects(:index).raises(exception)
    get '/console'
  end
end

