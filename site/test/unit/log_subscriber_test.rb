require File.expand_path('../../test_helper', __FILE__)

class LogSubscriberTest < ActiveSupport::TestCase

  def setup
    @subscriber = Streamline::LogSubscriber.new
    @subscriber.logger.level = 0
  end

  def event_with_response(response)
    ActiveSupport::Notifications::Event.new('test_event', Time.now, Time.now + 500, 4, {
      :url => 'http://fakeurl.com',
      :method => 'POST',
      :response => response
    })
  end

  test 'response with no sensitive info is logged' do
    @subscriber.expects(:debug).with { |msg| msg.include? "{ 'foo': 'bar' }"}
    @subscriber.request event_with_response("{ 'foo': 'bar' }")
  end

  test 'response with phoneNumber is ommitted' do
    @subscriber.expects(:debug).with { |msg| !msg.include? '555-123-4567' }
    @subscriber.request event_with_response("{ 'foo': 'bar', 'phoneNumber': '555-123-4567' }")
  end

  test 'response with emailAddress is ommitted' do
    @subscriber.expects(:debug).with { |msg| !msg.include? 'someyahoo@yahoo.com' }
    @subscriber.request event_with_response("{ 'emailAddress': 'someyahoo@yahoo.com' }")
  end

  test 'response with title is ommitted' do
    @subscriber.expects(:debug).with { |msg| !msg.include? 'Manager' }
    @subscriber.request event_with_response("{ 'bar': 'camp', 'title': 'Project Manager' }")
  end

  test 'response with an address is ommitted' do
    @subscriber.expects(:debug).with { |msg| !msg.include? '9876 West St.' }
    @subscriber.request event_with_response("{ 'address1': '9876 West St.' }")
  end

  test 'response with sensitive information contains [FILTERED]' do
    @subscriber.expects(:debug).with { |msg| msg.include? '[FILTERED]' }
    @subscriber.request event_with_response("{ 'bar': 'camp', 'emailAddress': 'foo@gmail.com' }")
  end
end
