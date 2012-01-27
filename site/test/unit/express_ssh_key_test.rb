require 'test_helper'

class ExpressSshKeyTest < ActiveSupport::TestCase

  test "initialize key" do
    type = "ssh-rsa"
    public_key = "AAAAsdasdfooobar"
    name = "test"

    key = ExpressSshKey.new({
      :public_key => public_key,
      :type => type,
      :name => name,
      :primary => false
    })

    assert_equal type, key.type
    assert_equal public_key, key.public_key
    assert_equal name, key.name
    assert !key.primary?
  end

  test "build key from string" do
    type = "ssh-rsa"
    public_key = "AAAAsdasdfooobar"
    name = "test"

    key = ExpressSshKey.build("#{type} #{public_key}", name, false)
    assert_equal type, key.type
    assert_equal public_key, key.public_key
    assert_equal name, key.name
    assert !key.primary?
  end

end
