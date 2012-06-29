require File.expand_path('../../test_helper', __FILE__)

require 'aria'

#
# Mock tests only - should verify functionality of ActiveResource extensions
# and simple server/client interactions via HttpMock
#
class AriaTest < ActiveSupport::TestCase
  setup { WebMock.disable_net_connect! }
  teardown { WebMock.allow_net_connect! }

  def stub_aria(method=nil)
    config = Rails.application.config
    stub_request(:post, config.aria_uri).
      with(:query => {
        :auth_key => config.aria_auth_key,
        :client_no => config.aria_client_no.to_s,
        :rest_call => method,
      })
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

    assert Aria.respond_to? :get_test

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

    assert a.respond_to? :get_test_raw
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
end
