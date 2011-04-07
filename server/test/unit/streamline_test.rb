require 'test_helper'

class StreamlineTest < ActiveSupport::TestCase

  def setup
    @streamline = Streamline.new
    @url = URI.parse("https://localhost/")
    @ticket = "0|abcdefghijlkmnop"
    Thread.current[:debugIO] = StringIO.new
  end

  test "streamline urls" do
    assert Streamline.login_url.host
    assert Streamline.request_access_url.host
    assert Streamline.roles_url.host
    assert Streamline.email_confirm_url("abc123", "test@example.com").query
  end

  test "parse ticket nil" do
    assert_nil = @streamline.parse_ticket(nil)
  end

  test "parse ticket empty" do
    assert_nil = @streamline.parse_ticket([])
  end

  test "parse ticket" do
    cookies = ["rh_sso=#{@ticket}; Domain=.redhat.com; Path=/; Secure;"]
    ticket = @streamline.parse_ticket(cookies)
    assert_equal ticket, @ticket
  end

  test "parse body nil" do
    assert_nil @streamline.parse_body(nil)
  end

  test "parse body" do
    body = {"test", "test2"}.to_json
    assert_not_nil @streamline.parse_body(body)
  end

  test "parse body errors" do
    body = {'errors' => ['login_required']}.to_json
    @streamline.parse_body(body)
  end

  test "parse errors nil" do
    @streamline.parse_json_errors(nil)
    assert @streamline.errors.empty?
  end

  test "parse errors empty" do
    json_errors = {}.to_json
    @streamline.parse_json_errors(json_errors)
    assert @streamline.errors.empty?
  end

  test "parse errors empty array" do
    json_errors = {"errors" => []}
    @streamline.parse_json_errors(json_errors)
    assert @streamline.errors.empty?
  end

  test "parse errors" do
    json_errors = {"errors" => ['email_required', 'user_already_registered']}
    @streamline.parse_json_errors(json_errors)
    assert !@streamline.errors.empty?
    assert_equal 1, @streamline.errors.length
    assert_equal 2, @streamline.errors.full_messages.length
  end

  test "http call success" do
    res = Net::HTTPSuccess.new('', '200', '')
    res.expects(:body).returns(nil)
    Net::HTTP.any_instance.expects(:start).returns(res)

    @streamline.http_post(@ticket, URI.parse("https://localhost/"))
  end

  test "http call redirect" do
    res = Net::HTTPSuccess.new('', '302', '')
    res.expects(:body).returns(nil)
    Net::HTTP.any_instance.expects(:start).returns(res)

    @streamline.http_post(@ticket, @url)
  end

  test "http call parsing ticket" do
    res = Net::HTTPSuccess.new('', '200', '')
    res.expects(:get_fields).returns(["rh_sso=#{@ticket}; Domain=.redhat.com; Path=/; Secure"])
    res.expects(:body).returns(nil)
    Net::HTTP.any_instance.expects(:start).returns(res)

    @streamline.http_post(@ticket, @url) do |ticket, json|
      assert ticket = @ticket
    end
  end

  test "http call not found" do
    res = Net::HTTPNotFound.new('', '404', '')
    Net::HTTP.any_instance.expects(:start).returns(res)

    assert_raise(Libra::StreamlineException) {
      @streamline.http_post(@ticket, @url)
    }
  end

  test "http call with bad body" do
    res = Net::HTTPSuccess.new('', '200', '')
    res.expects(:body).at_least_once.returns("{corrupt??#")
    Net::HTTP.any_instance.expects(:start).returns(res)

    assert_raise(Libra::StreamlineException) {
      @streamline.http_post(@ticket, @url)
    }

    # Make sure something was written to the client log
    assert !Thread.current[:debugIO].string.empty?
  end

  test "http call with exception" do
    res = Net::HTTPSuccess.new('', '200', '')
    res.expects(:body).at_least_once.raises(Exception, 'random http exception')
    Net::HTTP.any_instance.expects(:start).returns(res)

    assert_raise(Libra::StreamlineException) {
      @streamline.http_post(@ticket, @url)
    }

    # Make sure something was written to the client log
    assert !Thread.current[:debugIO].string.empty?
  end
end
