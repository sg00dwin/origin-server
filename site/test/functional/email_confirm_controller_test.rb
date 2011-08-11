require 'test_helper'

class EmailConfirmControllerTest < ActionController::TestCase
  test "error handling" do
    setup_session

    # call with no params
    get :confirm_express

    assert_template :error
  end

  test "confirm express" do
    setup_session
    res = Net::HTTPSuccess.new('', '200', '')
    res.expects(:body).at_least_once.returns({'emailAddress' => 'not_nil'}.to_json)
    Net::HTTP.any_instance.expects(:start).returns(res)

    get :confirm_express, {:key => 'test', :emailAddress => 'test'}

    assert_equal 'test', session[:confirm_login]
    assert_redirected_to express_path
  end

  test "confirm flex" do
    setup_session
    res = Net::HTTPSuccess.new('', '200', '')
    res.expects(:body).at_least_once.returns({'emailAddress' => 'not_nil'}.to_json)
    Net::HTTP.any_instance.expects(:start).returns(res)

    get :confirm_flex, {:key => 'test', :emailAddress => 'test'}

    assert_equal 'test', session[:confirm_login]
    assert_redirected_to flex_path
  end
end
