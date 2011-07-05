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
  
  test "create does not alter" do
    @domain.create
    assert !@domain.alter
  end
  
  test "create function calls save" do
    @domain.expects('save')
    @domain.create
  end
  
  test "update alters" do
    @domain.update
    assert @domain.alter
  end
  
  test "update function calls save" do
    @domain.expects('save')
    @domain.update
  end
end
