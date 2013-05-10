require File.expand_path('../../../test_helper', __FILE__)

class AccountHelperTest < ActionView::TestCase
  test 'usage amount singular' do
    assert_equal "1.0 gear-hour", usage_amount_with_units(1, 'gear-hour')
    assert_equal "1.0 gear-hour", usage_amount_with_units(1.0, 'gear-hour')
    assert_equal "1.0 gear-hour", usage_amount_with_units(1.01, 'gear-hour')
    assert_equal "1.0 gear-hour", usage_amount_with_units(0.99, 'gear-hour')
  end

  test 'usage amount plural' do
    assert_equal "0.0 gear-hours", usage_amount_with_units(0, 'gear-hour')
    assert_equal "0.1 gear-hours", usage_amount_with_units(0.1, 'gear-hour')
    assert_equal "1.1 gear-hours", usage_amount_with_units(1.1, 'gear-hour')
  end

  test 'usage amount rounding' do
    assert_equal "0.0 gear-hours", usage_amount_with_units(0, 'gear-hour')
    assert_equal "0.0 gear-hours", usage_amount_with_units(0.01, 'gear-hour')

    assert_equal "9.9 gear-hours", usage_amount_with_units(9.94, 'gear-hour')

    assert_equal "10 gear-hours", usage_amount_with_units(9.95, 'gear-hour')
    assert_equal "10 gear-hours", usage_amount_with_units(10.0, 'gear-hour')
    assert_equal "10 gear-hours", usage_amount_with_units(10.1, 'gear-hour')
  end

  test 'usage amount delimiters' do
    assert_equal "100 gear-hours", usage_amount_with_units(100, 'gear-hour')
    assert_equal "1,000 gear-hours", usage_amount_with_units(1000, 'gear-hour')
  end

end
