require 'test_helper'

class ExpressDomainTest < ActiveSupport::TestCase
  
  def setup
    @domain = ExpressDomain.new(
      :namespace => 'test_domain',
      :rhlogin => 'test@example.com',
      :password => 'secret'
    )
  end
  
  test "namespace should be present" do 
    @domain.namespace = nil
    assert !@domain.valid?
  end
  
  test "namespace should be alphanumeric" do
    @domain.namespace = '123*'
    assert !@domain.valid?
  end
  
  test "namespace should not be more than 16 characters" do
    @domain.namespace = 'morethansixteencharacters'
    assert !@domain.valid?
  end
  
end
