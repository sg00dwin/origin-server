# encoding: UTF-8

require File.expand_path('../../test_helper', __FILE__)

inline_test(File.expand_path(__FILE__))

class ApplicationTypesControllerTest < ActionController::TestCase
  def test_should_show_index_with_proper_title
    with_unique_user
    get :index
    assert_response :success
    assert_select 'head title', 'OpenShift Online by Red Hat'
  end

  test "should show default currency on index" do
    do_premium_indicator_index_test(nil, "$", ["C$","€"])
  end

  test "should show usd on index" do
    do_premium_indicator_index_test("usd", "$", ["C$","€"])
  end

  test "should show cad on index" do
    do_premium_indicator_index_test("cad", "C$", ["€"])
  end

  test "should show eur on index" do
    do_premium_indicator_index_test("eur", "€", ["$"])
  end


  test "should show default currency on create" do
    do_premium_indicator_create_test(nil, "$", ["C$","€"])
  end

  test "should show usd on create" do
    do_premium_indicator_create_test("usd", "$", ["C$","€"])
  end

  test "should show cad on create" do
    do_premium_indicator_create_test("cad", "C$", ["€"])
  end

  test "should show eur on create" do
    do_premium_indicator_create_test("eur", "€", ["$"])
  end

  protected
    def do_premium_indicator_index_test(currency_cd, currency_symbol, exclude_currency_symbols)
      type = ApplicationType.all.find(&:usage_rates?)
      omit("No premium application types configured; omitting test.") unless type

      with_unique_user

      if currency_cd
        @controller.expects(:user_currency_cd).at_least(0).returns(currency_cd)
      end

      with_unique_user
      get :index
      assert_response :success

      assert_select ".label-premium", {:text => currency_symbol}
      exclude_currency_symbols.each do |exclude_currency_symbol|
        assert_select ".label-premium", {:text => exclude_currency_symbol, :count => 0}
      end
    end

    def do_premium_indicator_create_test(currency_cd, currency_symbol, exclude_currency_symbols)
      type = ApplicationType.all.find(&:usage_rates?)
      omit("No premium application types configured; omitting test.") unless type

      with_unique_user

      if currency_cd
        @controller.expects(:user_currency_cd).at_least(0).returns(currency_cd)
      end

      with_unique_user
      get :show, :id => type.id
      assert_response :success

      assert_select ".label-premium", {:text => currency_symbol}
      exclude_currency_symbols.each do |exclude_currency_symbol|
        assert_select ".label-premium", {:text => exclude_currency_symbol, :count => 0}
      end

      assert_select "p strong", {:text => /#{Regexp.escape(currency_symbol)}/}
      exclude_currency_symbols.each do |exclude_currency_symbol|
        assert_select "p strong", {:text => /#{Regexp.escape(exclude_currency_symbol)}/, :count => 0}
      end
    end    

end
