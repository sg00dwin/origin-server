require File.expand_path('../../../test_helper', __FILE__)


class CountryHelperTest < ActionView::TestCase

  def test_countries_for_select
    countries = countries_for_select

    assert us = countries.find { |c| c[1] == 'US' }
    assert_equal 'USD',   us[2]['data-currency']
    assert_equal 'ZIP',   us[2]['data-postal_code']
    assert_equal 'State', us[2]['data-subdivision']

    assert ca = countries.find { |c| c[1] == 'CA' }
    assert_equal 'CAD',         ca[2]['data-currency']
    assert_equal 'Postal Code', ca[2]['data-postal_code']
    assert_equal 'Province',    ca[2]['data-subdivision']

    assert ie = countries.find { |c| c[1] == 'IE' }
    assert_equal 'EUR',      ie[2]['data-currency']
    assert_equal 'Postcode', ie[2]['data-postal_code']
    assert_equal 'Region',   ie[2]['data-subdivision']
  end

  def test_regions_for_select
    regions = regions_for_select

    # State - NC, US
    assert regions.find {|(country,regions)| country == 'United States' && regions.find {|(name,code,data)| code == 'NC' } }

    # Abbreviated region - Dublin, IE
    assert regions.find {|(country,regions)| country == 'Ireland' && regions.find {|(name,code,data)| code == 'D' } }

    # Unabbreviated region - Paris, FR
    assert regions.find {|(country,regions)| country == 'France' && regions.find {|(name,code,data)| code == 'Paris' } }
  end
end
