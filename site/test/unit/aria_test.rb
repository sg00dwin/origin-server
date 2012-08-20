require File.expand_path('../../test_helper', __FILE__)

require 'aria'

#
# Mock tests only - should verify functionality of ActiveResource extensions
# and simple server/client interactions via HttpMock
#
class AriaUnitTest < ActiveSupport::TestCase
  uses_http_mock
  setup { WebMock.disable_net_connect! }
  setup{ Rails.cache.clear }
  teardown { WebMock.allow_net_connect! }

  def query_for(method, query=nil)
    config = Rails.application.config
    {
      :auth_key => config.aria_auth_key,
      :client_no => config.aria_client_no.to_s,
      :rest_call => method.nil? ? nil : method.to_s,
    }.merge(query || {})
  end

  def stub_aria(method=nil, params=nil, partial=false)
    r = stub_request(:post, Rails.application.config.aria_uri)
    q = query_for(method)
    q = hash_including(q) if partial
    r.with(:query => q, :body => params).with do |request|
      request.headers['User-Agent'] == Rails.configuration.user_agent
    end
  end
  def error_wddx(code, message)
    {'error_code' => code, 'error_msg' => message}.to_wddx
  end
  def ok_wddx
    error_wddx(0, 'Ok')
  end
  def resp(*args)
    opts = args.extract_options!
    {:status => 200, :body => args[0] || ok_wddx}.merge!(opts).merge!(:headers => {'Content-Type' => 'text/html;charset=UTF-8'}.merge(opts[:headers] || {}))
  end

  test 'should not respond to object or module methods on Aria' do
    Aria.expects(:client).never
    assert Aria.respond_to? :public_instance_methods
    assert Aria.to_s
  end

  test 'should not respond to object methods on client' do
    Aria::Client.expects(:post).never
    c = Aria::Client.new
    assert !c.respond_to?(:before_remove_const)
    assert c.respond_to?(:to_s)
    assert c.to_s
  end

  test 'should support indifferent access' do
    s = Aria::WDDX::Struct.new('foo' => 1, 'other' => nil)

    assert s.respond_to?('foo')
    assert s.respond_to?(:foo)
    assert s.respond_to?('other')
    assert s.respond_to?(:other)
    assert !s.respond_to?(:bar)
    assert !s.respond_to?('bar')
    assert s.respond_to?(:[])
    assert s.respond_to?(:[]=)

    assert_equal 1, s[:foo]
    assert_equal 1, s['foo']
    assert_equal 1, s.foo

    assert_nil s[:other]
    assert_nil s['other']
    assert_nil s.other

    assert_equal 2, (s[:foo] = 2)
    assert_equal 2, s.foo
    assert_equal 3, (s['foo'] = 3)
    assert_equal 3, s.foo
    assert_equal 4, (s.foo = 4)
    assert_equal 4, s.foo

    assert_equal 1, (s[:other] = 1)
    assert_equal 1, s.other
    assert_nil s[:other] = nil
    assert_nil s.other

    assert_equal 1, (s['other'] = 1)
    assert_equal 1, s.other
    s[:other] = nil

    assert_equal 1, (s.other = 1)
    assert_equal 1, s.other
    s[:other] = nil

    assert_raise(NoMethodError){ s.bar }
    assert_nil s['bar']
    assert_nil s[:bar]

    assert_raise(NoMethodError){ s.bar = 2 }
    assert_equal 2, (s['bar'] = 2)
    assert_nil s.send(:[]=, 'bar', 2)
    assert_nil s['bar']
    assert_equal 2, (s[:bar] = 2)
    assert_nil s.send(:[]=, :bar, 2)
    assert_nil s[:bar]
  end

  test 'should form a simple request' do
    stub_aria(:get_test).to_return(resp)

    assert !Aria.respond_to?(:get_test)

    assert r = Aria.get_test
    assert_equal 0, r['error_code']
    assert_equal 0, r.error_code
    assert_equal 'Ok', r['error_msg']
    assert_equal 'Ok', r.error_msg
  end

  test 'should query raw requests' do
    stub_aria(:get_test).to_return(resp)

    a = Aria
    a.expects(:get_test).never

    assert !a.respond_to?(:get_test_raw)
    assert r = a.get_test_raw
    assert_equal 200, r.code
    assert_equal 0, r.data['error_code']
    assert_equal 0, r.data.error_code
    assert_equal 'Ok', r.data['error_msg']
    assert_equal 'Ok', r.data.error_msg
  end

  test 'should yield response' do
    stub_aria(:get_test).to_return(resp)
    y = Aria.get_test do |data, r|
      assert data
      assert_equal 0, data.error_code
      assert_equal 200, r.code
      -3
    end
    assert_equal -3, y
  end

  test 'should raise generic' do
    stub_aria(:get_test).to_return(resp(error_wddx(1000,'Unknown')))
    e = assert_raise(Aria::Error){ Aria.get_test }
    assert_equal 'Unknown', e.data['error_msg']
    assert_equal 'Unknown', e.data[:error_msg]
    assert_equal 'Unknown', e.data.error_msg
    assert_equal 1000, e.code
    assert e.to_s =~ /\(1000\)/
  end

  test 'should have default_plan_no' do
    assert Aria.default_plan_no.is_a? Fixnum
    assert Aria.default_plan_no > 0
  end

  test 'should have client_no' do
    assert Aria.client_no.is_a? Fixnum
    assert Aria.client_no > 0
  end

  test 'should raise ParameterMissing' do
    stub_aria(:get_test).to_return(resp(error_wddx(1010,'Missing required parameter')))
    e = assert_raise(Aria::MissingRequiredParameter){ Aria.get_test }
    assert_equal 1010, e.code
    assert_equal 'Missing required parameter (1010)', e.to_s
  end

  test 'should raise unavailable on 503' do
    stub_aria(:get_test).to_return(:status => 503)
    e = assert_raise(Aria::NotAvailable){ Aria.get_test }
    assert_equal 503, e.response.code
  end

  test 'should raise unavailable on 404' do
    stub_aria(:get_test).to_return(:status => 404)
    e = assert_raise(Aria::NotAvailable){ Aria.get_test }
    assert_equal 404, e.response.code
  end

  test 'should raise invalid method on 404' do
    stub_aria(:get_test).to_return(resp(error_wddx(-1, 'Not attempted'), :status => 404 ))
    e = assert_raise(Aria::InvalidMethod){ Aria.get_test }
  end

  test 'should return false on create_account error' do
    user = Object.new.extend(ActiveModel::Validations).extend(Aria::User)
    user.expects(:login).returns('foo').at_least_once
    Aria.expects(:create_acct_complete).raises(Aria::AuthenticationError)
    assert !user.create_account
    assert user.errors.length == 1
    assert user.errors[:base][0] =~ /AuthenticationError/, user.errors.inspect
  end

  test 'should invoke create_acct_complete' do
    stub_aria(:create_acct_complete, {
      :supp_field_values => 'foo',
      :supp_field_names => 'rhlogin',
      :password => 'passw0rd',
      :test_acct_ind => 1.to_s,
      :status_cd => 0.to_s,
      :master_plan_no => Rails.application.config.aria_default_plan_no.to_s,
      :userid => Digest::MD5::hexdigest('foo'),
    }).to_return(resp(ok_wddx))

    user = Object.new.extend(ActiveModel::Validations).extend(Aria::User)
    user.expects(:random_password).returns('passw0rd')
    user.expects(:login).returns('foo').at_least_once
    assert user.create_account
    assert user.errors.empty?
  end

  test 'get_acct_no_from_user_id is cacheable' do
    Aria::Client.any_instance.expects(:invoke).once.
      with(:get_acct_no_from_user_id, {:user_id => 'foo'}).
      returns(Aria::WDDX::Struct.new({'acct_no' => '1'}))
    assert_equal '1', Aria.cached.get_acct_no_from_user_id('foo')
    assert_equal '1', Aria.cached.get_acct_no_from_user_id('foo')
  end

  def mock_plans
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get '/broker/rest/plans/freeshift.json', anonymous_json_header, {:id => 'freeshift', :plan_no => '1'}.to_json
      mock.get '/broker/rest/plans/megashift.json', anonymous_json_header, {:id => 'megashift', :plan_no => '2'}.to_json
    end
    Aria::Client.any_instance.expects(:invoke).once.
      with(:get_client_plans_basic).
      returns(Aria::WDDX::Struct.new({
        'plans_basic' => [
          Aria::WDDX::Struct.new({
            'plan_no' => '1',
            'plan_name' => 'FreeShift',
          }),
          Aria::WDDX::Struct.new({
            'plan_no' => '2',
            'plan_name' => 'MegaShift',
          })
        ]
      }))
  end

  test 'Aria::MasterPlan.find is cacheable' do
    mock_plans
    assert Aria.cached.get_client_plans_basic
    assert_equal 2, Aria.cached.get_client_plans_basic.length
    assert_equal 'FreeShift', Aria::MasterPlan.cached.find('freeshift').name
    assert_equal 'FreeShift', Aria::MasterPlan.cached.find('freeshift').name

    assert_equal 'MegaShift', Aria::MasterPlan.cached.find('megashift').name
  end

  test 'Aria::MasterPlan can lazy load aria_plan with cache' do
    mock_plans
    base_plan = Aria::MasterPlan.cached.find('freeshift')
    cached_plan = Aria::MasterPlan.cached.find('freeshift')
    assert_equal 'FreeShift', cached_plan.name
  end

  test 'should throw when non hash passed' do
    assert_raise(ArgumentError){ Aria.get_test 'hello' }
  end

  test 'billing info should init from billing details' do
    attr = Aria::WDDX::Struct.new({'billing' => 'a', 'billing_city' => 'Houston', 'billing_address1' => '1 test', 'other' => '2'})
    assert info = Aria::BillingInfo.from_account_details(attr)
    assert info.persisted?
    assert_equal 'Houston', info.city
    assert_equal({'city' => 'Houston', 'address1' => '1 test'}, info.attributes)
    assert_equal({'bill_city' => 'Houston', 'bill_address1' => '1 test'}, info.to_aria_attributes)
    #assert_nil info.tax_exempt
    #assert !info.tax_exempt?
  end

  test 'billing info should serialize supplemental fields' do
    #info = Aria::BillingInfo.new
    #info.tax_exempt = 1
    #assert_equal({:supplemental => {'tax_exempt' => 1}}, info.to_aria_attributes)
  end

  test 'create_acct_complete should serialize supplemental fields' do
    base = Class.new(Object){ def create_acct_complete(*args) has(*args) end }
    a = Class.new(base){ include Aria::Methods }.new
    a.expects(:has).with({
      :supp_field_names => 'tax_exempt',
      :supp_field_values => '1',
    },nil)
    a.create_acct_complete({:supplemental => {'tax_exempt' => 1}})
  end

  test 'update_acct_complete should serialize supplemental fields' do
    base = Class.new(Object){ def update_acct_complete(*args) has(*args) end }
    a = Class.new(base){ include Aria::Methods }.new
    a.expects(:has).with({
      :acct_no => 1,
      :supp_field_names => 'tax_exempt',
      :supp_field_values => '1',
      :supp_field_directives => '2',
    },nil)
    a.update_acct_complete(1, {:supplemental => {'tax_exempt' => 1}})
  end

  test 'direct_post should not generate names when not configured' do
    Rails.configuration.expects(:aria_direct_post_name).at_least_once.returns(nil)
    assert_nil Aria::DirectPost.get_configured
    assert_nil Aria::DirectPost.get_configured('bar')
  end

  test 'direct_post should generate names when configured' do
    Rails.configuration.expects(:aria_direct_post_name).at_least_once.returns('foo')
    assert_equal 'foo', Aria::DirectPost.get_configured
    assert_equal 'foo_bar', Aria::DirectPost.get_configured('bar')
  end

  test 'payment_method should initialize from account details' do
    assert p = Aria::PaymentMethod.from_account_details(stub(
      :pay_method => '1',
      :attributes => {
        :cc_expire_mm => '10',
        :cc_expire_yyyy => '2015',
        :cc_suffix => '1111'
      }
    ))
    assert_equal '1111', p.cc_no
    assert_equal '10', p.cc_exp_mm
    assert_equal '2015', p.cc_exp_yyyy
    assert p.persisted?
  end

  test 'validates values for create account' do
    user = Object.new.extend(ActiveModel::Validations).extend(Aria::User)
    user.expects(:login).at_least_once.returns('foo')
    billing_info = Aria::BillingInfo.new
    assert !user.create_account(:billing_info => billing_info)
    assert user.errors.empty?
    assert !billing_info.errors.empty?
  end

  test 'validates values for update account' do
    user = Object.new.extend(ActiveModel::Validations).extend(Aria::User)
    billing_info = Aria::BillingInfo.new
    assert !user.update_account(:billing_info => billing_info)
    assert user.errors.empty?
    assert !billing_info.errors.empty?
  end

  test 'payment_method is only persisted when account_details pay_method is 1' do
    assert p = Aria::PaymentMethod.from_account_details(stub(
      :pay_method => '0',
      :attributes => {
        :cc_expire_mm => '10',
        :cc_expire_yyyy => '2015',
        :cc_suffix => '1111'
      }
    ))
    assert !p.persisted?
  end
  
  test 'master plan adds aria plan details to broker plans' do
    Aria::Client.any_instance.expects(:invoke).once.
      with(:get_client_plans_basic).
      returns(Aria::WDDX::Struct.new({
        'plans_basic' => [
          Aria::WDDX::Struct.new({
            'plan_no' => '1',
            'plan_name' => 'FreeShift',
            'plan_desc' => 'FreeShift description'
          }),
          Aria::WDDX::Struct.new({
            'plan_no' => '2',
            'plan_name' => 'MegaShift',
            'plan_desc' => 'MegaShift description'
          })
        ]
      }))

    assert plan = Aria::MasterPlan.new(
      :plan_no => '1',
      :capabilities => { :max_gears => 3, :gear_sizes => ['small'] }
    )
    assert_equal 'FreeShift', plan.name
    assert_equal 'FreeShift description', plan.description
    assert_equal 3, plan.max_gears
    assert_equal ['small'], plan.gear_sizes
    
    # The aria plan object should be protected.
    assert_raise(NoMethodError) { plan.aria_plan }
  end
end
