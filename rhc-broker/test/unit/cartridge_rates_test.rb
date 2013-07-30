require 'test_helper'
require 'mocha/setup'

module Rails
  def self.logger
    l = Mocha::Mock.new("logger")
    l.stubs(:debug)
    l.stubs(:info)
    l.stubs(:add)
    l
  end
end

class CartridgeRatesTest < ActionDispatch::IntegrationTest

  test "cartridge rates test" do
    carts = CartridgeCache.cartridges
    carts.each do |cart|
      ur = cart.usage_rates
      assert_equal ur.class, Array
      next if ur.empty?
      ur.each { |rate|
        assert_equal true, (rate.has_key? "plan_id")
        assert_equal true, (rate.has_key? :usd)
        assert_equal true, (rate.has_key? :cad)
        assert_equal true, (rate.has_key? :eur)
        assert_equal true, (rate.has_key? :duration)
      }
    end
  end

  def teardown
    Mocha::Mockery.instance.stubba.unstub_all
  end
end
