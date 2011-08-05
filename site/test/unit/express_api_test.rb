require 'test_helper'

# mixin class
class ExpressApiTester
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Serialization
  extend ActiveModel::Naming
  
  include ExpressApi
  
  attr_accessor :password, :errors
  
  def initialize
    @errors = ActiveModel::Errors.new(self)
  end
  
end

class ExpressApiTest < ActiveSupport::TestCase
  
  def setup
    @api = ExpressApiTester.new
    @api.password = 'secret'
    @url = URI.parse("https://localhost/")
    @data = ActiveSupport::JSON.encode({:test => '123'})
  end
  
  test "json response is read" do
    response = Net::HTTPSuccess::new('', '200', '')
    response.add_field 'Content-Type', 'application/json'
    response.expects(:body).returns(nil)
    Net::HTTP.any_instance.expects(:start).returns(response)
    
    @api.http_post(@url, @data)
  end
  
  test "json response yields with json" do
    response = Net::HTTPSuccess::new('', '200', '')
    response.add_field 'Content-Type', 'application/json'
    json_body = ActiveSupport::JSON.encode({:test_response => '456'})
    response.expects(:body).at_least_once().returns(json_body)
    Net::HTTP.any_instance.expects(:start).returns(response)
    
    @api.http_post(@url, @data) do |json|
      assert_equal(ActiveSupport::JSON.encode(json), json_body)
    end
  end
  
  test "http post forbidden generates error" do 
    response = Net::HTTPForbidden::new('', '403', '')
    Net::HTTP.any_instance.expects(:start).returns(response)
    
    @api.http_post(@url, @data)
    
    assert_equal(I18n.t('express_api.errors.unauthorized'), @api.errors[:base][0])
  end
  
  test "http post unauthorized generates error" do
    response = Net::HTTPUnauthorized::new('', '401', '')
    Net::HTTP.any_instance.expects(:start).returns(response)
    
    @api.http_post(@url, @data)
    
    assert_equal(I18n.t('express_api.errors.unauthorized'), @api.errors[:base][0])
  end

end
