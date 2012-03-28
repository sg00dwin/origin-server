require 'test_helper'
require 'stickshift-controller'
require 'mocha'

module Rails
  def self.logger
    l = Mocha::Mock.new("logger")
    l.expects(:debug)
    l
  end
end

class RestReplyTest < ActiveSupport::TestCase
  # 
  test "xml response" do
    user = CloudUser.new("testuser")
    domain = Domain.new("test1", user)
    rest_domain = RestDomain.new(domain)
    response = RestReply.new(:ok, "domain", rest_domain)
    puts response.to_xml()
  end
end