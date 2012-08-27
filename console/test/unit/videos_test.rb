require File.expand_path('../../test_helper', __FILE__)

# some representative IPs
LOCALHOST = "127.0.0.1"
YAHOO_COM = "98.139.180.149"
YAHOO_DE = "87.248.120.148"
EN_CHINA_CN = "124.238.254.71"

class ExpressControllerTest < ActiveSupport::TestCase

  test 'should except upon invalid video key' do
    @controller = DummyController.new(LOCALHOST)
    assert_raise( StandardError ) { @controller.local_video('foo') }
  end

  test 'should provide tudou info in China' do
    key = 'express_client_tools'
    ips = [EN_CHINA_CN]

    ips.each { |ip|
      @controller = DummyController.new(ip)
      vid = @controller.local_video(key)
    
      assert_equal :tudou, vid[:provider]
      assert_equal 'MUx16XMfBi0', vid[:id]

      assert_equal 'http://www.tudou.com/programs/view/MUx16XMfBi0/', @controller.local_video_url(key)
    }
  end

  test 'should provide youtube info elsewhere' do
    key = 'express_client_tools'
    ips = [LOCALHOST, YAHOO_COM, YAHOO_DE]

    ips.each { |ip|
      @controller = DummyController.new(ip)
      vid = @controller.local_video(key)
    
      assert_equal :youtube, vid[:provider]
      assert_equal 'KLtbuvyJFFE', vid[:id]

      assert_equal 'http://www.youtube.com/watch?v=KLtbuvyJFFE', @controller.local_video_url(key)
    }
  end

  # helper classes

  class DummyRequest
    attr_accessor :remote_ip

    def initialize(ip)
      @remote_ip = ip
    end
  end

  class DummyController
    include ApplicationHelper

    attr_accessor :request

    def initialize(remote_ip)
      @request = DummyRequest.new(remote_ip)
    end
  end

end
