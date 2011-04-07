require 'test_helper'

class StreamlineTest < ActiveSupport::TestCase

  def setup
    @streamline = Streamline.new
    @url = URI.parse("https://localhost/")
    @ticket = "0|abcdefghijlkmnop"
    Thread.current[:debugIO] = StringIO.new
  end

  test "streamline urls" do
    assert Streamline.email_confirm_url("abc123", "test@example.com").query
  end

  test "parse ticket nil" do
    @streamline.parse_ticket(nil)
    assert_nil @streamline.ticket
  end

  test "parse ticket empty" do
    @streamline.parse_ticket([])
    assert_nil @streamline.ticket
  end

  test "parse ticket" do
    cookies = ["rh_sso=#{@ticket}; Domain=.redhat.com; Path=/; Secure;"]
    @streamline.parse_ticket(cookies)
    assert_equal @streamline.ticket, @ticket
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

    @streamline.http_post(@url)
  end

  test "http call redirect" do
    res = Net::HTTPSuccess.new('', '302', '')
    res.expects(:body).returns(nil)
    Net::HTTP.any_instance.expects(:start).returns(res)

    @streamline.http_post(@url)
  end

  test "http call parsing ticket" do
    res = Net::HTTPSuccess.new('', '200', '')
    res.expects(:get_fields).returns(["rh_sso=#{@ticket}; Domain=.redhat.com; Path=/; Secure"])
    res.expects(:body).returns(nil)
    Net::HTTP.any_instance.expects(:start).returns(res)

    @streamline.http_post(@url)
    assert_equal @streamline.ticket, @ticket
  end

  test "http call not found" do
    res = Net::HTTPNotFound.new('', '404', '')
    Net::HTTP.any_instance.expects(:start).returns(res)

    assert_raise(Libra::StreamlineException) {
      @streamline.http_post(@url)
    }
  end

  test "http call with bad body" do
    res = Net::HTTPSuccess.new('', '200', '')
    res.expects(:body).at_least_once.returns("{corrupt??#")
    Net::HTTP.any_instance.expects(:start).returns(res)

    assert_raise(Libra::StreamlineException) {
      @streamline.http_post(@url)
    }

    # Make sure something was written to the client log
    assert !Thread.current[:debugIO].string.empty?
  end

  test "http call with exception" do
    res = Net::HTTPSuccess.new('', '200', '')
    res.expects(:body).at_least_once.raises(Exception, 'random http exception')
    Net::HTTP.any_instance.expects(:start).returns(res)

    assert_raise(Libra::StreamlineException) {
      @streamline.http_post(@url)
    }

    # Make sure something was written to the client log
    assert !Thread.current[:debugIO].string.empty?
  end

  test "login valid" do
    email = "test@example.com"
    roles = ['authenticated']
    json = {"username" => email, "roles" => roles}
    @streamline.stubs(:http_post).yields(json)
    @streamline.login(email, "password")
    assert_equal roles, @streamline.roles
    assert @streamline.errors.empty?
  end

  test "register valid" do
    email = "test@example.com"
    json = {"emailAddress" => email}
    @streamline.expects(:http_post).once.yields(json)
    @streamline.register(email, "test", @url)
    assert @streamline.errors.empty?
  end

  test "register fail" do
    email = "test@example.com"
    json = {"bad" => "bad"}
    @streamline.expects(:http_post).once.yields(json)
    @streamline.register(email, "test", @url)
    assert !@streamline.errors.empty?
  end

  test "role has access" do
    @streamline.roles << CloudAccess.auth_role(CloudAccess::EXPRESS)
    assert @streamline.has_access?(CloudAccess::EXPRESS)
    assert !@streamline.has_requested?(CloudAccess::EXPRESS)
  end

  test "role requested access" do
    @streamline.roles << CloudAccess.req_role(CloudAccess::EXPRESS)
    assert !@streamline.has_access?(CloudAccess::EXPRESS)
    assert @streamline.has_requested?(CloudAccess::EXPRESS)
  end

  test "request access" do
    @streamline.expects(:http_post).once
    @streamline.request_access(CloudAccess::EXPRESS, "1234")
    assert @streamline.errors.empty?
  end

  test "request access multiple" do
    @streamline.roles << CloudAccess.req_role(CloudAccess::EXPRESS)
    @streamline.expects(:http_post).never
    @streamline.request_access(CloudAccess::EXPRESS, "1234")
    assert @streamline.errors.empty?
  end

  test "request access already has" do
    @streamline.roles << CloudAccess.auth_role(CloudAccess::EXPRESS)
    @streamline.expects(:http_post).never
    @streamline.request_access(CloudAccess::EXPRESS, "1234")
    assert @streamline.errors.empty?
  end

  test "establish user" do
    login = "test@example.com"
    roles = ['authenticated']
    json = {"username" => login, "roles" => roles}
    @streamline.expects(:http_post).once.yields(json)
    est_login = @streamline.establish
    assert_equal login, est_login
    assert_equal roles, @streamline.roles
  end
end
