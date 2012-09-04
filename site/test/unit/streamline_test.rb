require File.expand_path('../../test_helper', __FILE__)

# Define a test class to mixin the module
class StreamlineTester < Streamline::Base
  include ActiveModel::Naming
  include Streamline::User

  attr_accessor :terms_accepted
  # Make these items public for test purposes
  attr_writer :ticket, :terms, :email_address

  def self.register_url
    superclass.send(:class_variable_get, :@@register_url)
  end
end

class StreamlineUnitTest < ActiveSupport::TestCase

  setup { Rails.cache.clear }

  def setup
    @streamline = StreamlineTester.new
    @url = URI.parse("https://localhost/")
    @ticket = "0|abcdefghijlkmnop"
#    Thread.current[:debugIO] = StringIO.new
#    Thread.current[:messageIO] = StringIO.new
  end

  def set_roles(roles)
    @streamline.instance_variable_set("@roles", roles)
  end

  def establish(roles, username=nil)
    [roles, username, @streamline.expects(:http_post).yields({'roles' => roles, 'username' => username}).returns(roles)]
  end

  test "parse ticket nil" do
    @streamline.send(:parse_ticket, nil)
    assert_nil @streamline.ticket
  end

  test "parse ticket empty" do
    @streamline.send(:parse_ticket, [])
    assert_nil @streamline.ticket
  end

  test "parse ticket" do
    cookies = ["rh_sso=#{@ticket}; Domain=.redhat.com; Path=/; Secure;"]
    @streamline.send(:parse_ticket, cookies)
    assert_equal @streamline.ticket, @ticket
  end

  test "parse body nil" do
    assert_nil @streamline.send(:parse_body, nil)
  end

  test "parse body" do
    body = {"test" => "test2"}.to_json
    assert_not_nil @streamline.send(:parse_body, body)
  end
  
  test "should raise when parse malformed JSON" do
    assert_raise(MultiJson::DecodeError){ @streamline.send(:parse_body, "{json: 'foo'") }
  end

  test "parse body errors" do
    body = {'errors' => ['login_required']}.to_json
    @streamline.send(:parse_body, body)
  end

  test "build terms query nil" do
    assert_nil @streamline.send(:build_terms_query, nil)
  end

  test "build terms query" do
    terms = [{'termId' => 1, 'termUrl' => 'http://test'}, {'termId' => 2, 'termUrl' => 'http://test2'}]
    assert_equal 'termIds=1&termIds=2', @streamline.send(:build_terms_query, terms)
  end

  test "build terms url" do
    terms = ['1', '2']
    url = @streamline.send(:build_terms_url, terms)
    assert url.to_s =~ /^http.*\?termIds=/
  end

  test "parse errors nil" do
    @streamline.send(:parse_json_errors, nil)
    assert @streamline.errors.empty?
  end

  test "parse errors empty" do
    json_errors = {}.to_json
    @streamline.send(:parse_json_errors, json_errors)
    assert @streamline.errors.empty?
  end

  test "parse errors empty array" do
    json_errors = {"errors" => []}
    @streamline.send(:parse_json_errors, json_errors)
    assert @streamline.errors.empty?
  end

  test "parse errors" do
    json_errors = {"errors" => ['email_required', 'user_already_registered']}
    @streamline.send(:parse_json_errors, json_errors)
    assert !@streamline.errors.empty?
    assert_equal 2, @streamline.errors.size
    assert_equal 2, @streamline.errors.full_messages.length
  end

  test "http call success" do
    res = Net::HTTPSuccess.new('', '200', '')
    res.expects(:body).at_least_once.returns('{}')
    Net::HTTP.any_instance.expects(:start).returns(res)

    @streamline.send(:http_post, @url)
  end

  test "sets user agent" do
    res = Net::HTTPSuccess.new('', '200', '')
    res.expects(:body).at_least_once.returns('{}')
    Net::HTTP.any_instance.expects(:request).with do |req|
      req['User-Agent'] == Rails.configuration.user_agent
    end.returns(res)
    @streamline.send(:http_post, @url)
  end

  test "http call redirect" do
    res = Net::HTTPSuccess.new('', '302', '')
    res.expects(:body).at_least_once.returns('{}')
    Net::HTTP.any_instance.expects(:start).returns(res)

    @streamline.send(:http_post, @url)
  end

  test "http call parsing ticket" do
    res = Net::HTTPSuccess.new('', '200', '')
    res.expects(:get_fields).returns(["rh_sso=#{@ticket}; Domain=.redhat.com; Path=/; Secure"])
    res.expects(:body).at_least_once.returns('{}')
    Net::HTTP.any_instance.expects(:start).returns(res)

    @streamline.send(:http_post, @url)
    assert_equal @streamline.ticket, @ticket
  end

  test "http call not found" do
    res = Net::HTTPNotFound.new('', '404', '')
    Net::HTTP.any_instance.expects(:start).returns(res)

    assert_raise(Streamline::StreamlineException) {
      @streamline.send(:http_post, @url)
    }
  end

  test "http call with 200 and bad content" do
    res = Net::HTTPSuccess.new('', '200', '')
    res.expects(:body).at_least_once.returns("{")
    Net::HTTP.any_instance.expects(:start).returns(res)

    assert_raise(Streamline::StreamlineException) {
      @streamline.send(:http_post, @url)
    }
    assert @streamline.errors[:base].all?{ |s| s =~ (/system error has occurred./) }
  end

  test "http call with 401 and bad content" do
    res = Net::HTTPUnauthorized.new('', '401', '')
    res.expects(:body).at_least_once.returns("<html></html>")
    Net::HTTP.any_instance.expects(:start).returns(res)

    assert_raise(AccessDeniedException) {
      @streamline.send(:http_post, @url)
    }
    assert @streamline.errors[:base].all?{ |s| s =~ (/system error has occurred./) }
  end

  test "http call with 401 and service errors" do
    res = Net::HTTPUnauthorized.new('', '401', '')
    res.expects(:body).at_least_once.returns('{"errors":["service_error"]}')
    Net::HTTP.any_instance.expects(:start).returns(res)

    assert_raise(Streamline::StreamlineException) do
      @streamline.send(:http_post, @url)
    end
    assert @streamline.errors[:base].all?{ |s| s =~ (/system error has occurred./) }
  end

  test "http call with 401 and empty body" do
    res = Net::HTTPUnauthorized.new('', '401', '')
    res.expects(:body).at_least_once.returns("")
    Net::HTTP.any_instance.expects(:start).returns(res)

    assert_raise(AccessDeniedException) {
      @streamline.send(:http_post, @url)
    }
    assert @streamline.errors[:base].all?{ |s| s =~ (/system error has occurred./) }
  end

  test "http call with bad body" do
    res = Net::HTTPSuccess.new('', '200', '')
    res.expects(:body).at_least_once.returns("{corrupt??#")
    Net::HTTP.any_instance.expects(:start).returns(res)

    assert_raise(Streamline::StreamlineException) {
      @streamline.send(:http_post, @url)
    }

    # Make sure something was written to the client log
    #assert !Thread.current[:debugIO].string.empty?
  end

  test "http call with exception" do
    res = Net::HTTPSuccess.new('', '200', '')
    res.expects(:body).at_least_once.raises(Exception, 'random http exception')
    Net::HTTP.any_instance.expects(:start).returns(res)

    assert_raise(Streamline::StreamlineException) {
      @streamline.send(:http_post, @url)
    }

    # Make sure something was written to the client log
    #assert !Thread.current[:debugIO].string.empty?
  end

  test "register valid" do
    @streamline.email_address = "test@example.com"
    @streamline.password = "password"
    json = {"emailAddress" => @streamline.email_address}
    args = json.merge({
      'password' => @streamline.password,
      'passwordConfirmation' => @streamline.password,
      'secretKey' => Rails.configuration.streamline[:register_secret],
      'termsAccepted' => 'true',
      'confirmationUrl' => @url,
    })
    @streamline.expects(:http_post).with(@streamline.send(:register_url), args, false).once.yields(json)
    @streamline.register(@url)
    assert @streamline.errors.empty?
  end

  test "register valid promo code" do
    @streamline.email_address = "test@example.com"
    @streamline.password = "password"
    json = {"emailAddress" => @streamline.email_address}
    args = json.merge({
      'password' => @streamline.password,
      'passwordConfirmation' => @streamline.password,
      'secretKey' => Rails.configuration.streamline[:register_secret],
      'termsAccepted' => 'true',
      'promoCode' => 'promo_foo',
      'confirmationUrl' => @url,
    })
    @streamline.expects(:http_post).with(@streamline.send(:register_url), args, false).once.yields(json)
    @streamline.register(@url, 'promo_foo')
    assert @streamline.errors.empty?
  end


  test "register fail" do
    @streamline.email_address = "test@example.com"
    @streamline.password = "password"
    json = {"bad" => "bad"}
    @streamline.expects(:http_post).once.yields(json)
    @streamline.register(@url)
    assert !@streamline.errors.empty?
  end

  test "role is loaded once" do
    json = {"roles" => []}
    @streamline.expects(:http_post).once.yields(json).returns(json['roles'])
    assert_equal [], @streamline.roles
    assert_equal [], @streamline.roles
  end

  test "role has access" do
    @streamline.expects(:http_post).never
    set_roles [CloudAccess.auth_role(CloudAccess::EXPRESS)]
    assert @streamline.has_access?(CloudAccess::EXPRESS)
    assert !@streamline.has_requested?(CloudAccess::EXPRESS)
  end

  test "role requested access" do
    @streamline.expects(:http_post).never
    set_roles [CloudAccess.req_role(CloudAccess::EXPRESS)]
    assert !@streamline.has_access?(CloudAccess::EXPRESS)
    assert @streamline.has_requested?(CloudAccess::EXPRESS)
  end

  test "request access" do
    @streamline.expects(:http_post).once
    @streamline.request_access(CloudAccess::EXPRESS)
    assert @streamline.errors.empty?
  end

  test "request access multiple" do
    @streamline.expects(:http_post).never
    set_roles [CloudAccess.req_role(CloudAccess::EXPRESS)]
    @streamline.request_access(CloudAccess::EXPRESS)
    assert @streamline.errors.size == 1
  end

  test "request access already has" do
    @streamline.expects(:http_post).never
    set_roles [CloudAccess.auth_role(CloudAccess::EXPRESS)]
    @streamline.request_access(CloudAccess::EXPRESS)
    assert @streamline.errors.size == 1
  end

  test "establish roles implicitly" do
    roles, username = establish([CloudAccess.auth_role(CloudAccess::EXPRESS)], 'test@example.com')
    assert_equal roles, @streamline.roles
    assert_equal roles, @streamline.roles # check for caching values
  end

  test "entitle checks roles implicitly" do
    roles, username = establish([CloudAccess.auth_role(CloudAccess::EXPRESS)], 'test@example.com')
    assert @streamline.entitled?
    assert @streamline.entitled? # check for caching value
  end
  
  test "entitle depends on req role" do
    roles, username = establish([CloudAccess.req_role(CloudAccess::EXPRESS)], 'test@example.com')
    assert_equal false, @streamline.entitled?
    assert_equal false, @streamline.entitled? #check for caching value
  end

  test "waiting for entitle checks roles implicitly" do
    roles, username = establish([CloudAccess.req_role(CloudAccess::EXPRESS)], 'test@example.com')
    assert @streamline.waiting_for_entitle?
    assert @streamline.waiting_for_entitle? # check for caching value
  end

  test "waiting for entitle false when role exists" do
    roles, username = establish([CloudAccess.auth_role(CloudAccess::EXPRESS)], 'test@example.com')
    assert_equal false, @streamline.waiting_for_entitle?
    assert_equal false, @streamline.waiting_for_entitle? # check for caching value
  end

  test "establish user" do
    roles, username = establish(['authenticated'], 'test@example.com')
    Rails.logger.expects(:warn).never
    assert_equal @streamline, @streamline.establish
    assert_equal username, @streamline.rhlogin
    assert_equal roles, @streamline.roles
  end

  test 'should check validators on password confirmation' do
    @streamline.password = 'foobar'
    @streamline.old_password = 'old'
    @streamline.password_confirmation = 'bar'
    assert !@streamline.valid?(:change_password)
    assert @streamline.errors[:password].first =~ /match/, @streamline.errors.inspect
  end

  test "establish user warns on name change" do
    user = states('user').starts_as('normal')

    roles = ['authenticated']

    @streamline.expects(:http_post).yields({
      'roles' => roles, 
      'username' => 'test@example.com'
    }).returns(roles).when(user.is('normal'))
    Rails.logger.expects(:warn).never.when(user.is('normal'))

    @streamline.expects(:http_post).yields({
      'roles' => roles, 
      'username' => 'test2@example.com'
    }).returns(roles).when(user.is('changed'))
    Rails.logger.expects(:warn).once.when(user.is('changed'))

    @streamline.establish
    set_roles nil
    user.become('changed')
    @streamline.establish
  end

  test "get email address for user" do
    email_address = 'test@example.com'
    json = {"emailAddress" => email_address}
    @streamline.expects(:http_post).once.yields(json).returns(email_address)
    assert_equal email_address, @streamline.load_email_address
    assert_equal email_address, @streamline.email_address
  end

  test "email address lookup is cached" do
    s1 = StreamlineTester.new
    s1.send(:rhlogin=, 'user1')
    s1.expects(:http_post).once.returns('user1@user1.com')
    assert_equal 'user1@user1.com', s1.load_email_address

    s2 = StreamlineTester.new
    s2.send(:rhlogin=, 'user1')
    s2.expects(:http_post).never #comes from cache
    assert_equal 'user1@user1.com', s2.load_email_address

    s3 = StreamlineTester.new
    s3.send(:rhlogin=, 'user2')
    s3.expects(:http_post).once.returns('user2@user2.com')
    assert_equal 'user2@user2.com', s3.load_email_address

    Rails.cache.clear
    s4 = StreamlineTester.new
    s4.send(:rhlogin=, 'user1')
    s4.expects(:http_post).once.returns('user1@user1.com') #cache was cleared
    assert_equal 'user1@user1.com', s4.load_email_address
  end

  test "establish terms existing" do
    @streamline.terms = {}
    @streamline.expects(:http_post).never
    @streamline.establish_terms
  end

  test "establish terms" do
    terms = [{"termId" => 1, "termUrl" => "http://www.redhat.com/term1"}]
    json = {"unacknowledgedTerms" => terms}
    @streamline.expects(:http_post).once.yields(json).returns(terms)
    @streamline.establish_terms
    assert_equal 1, @streamline.terms.length
  end

  test "establish site terms" do
    terms = [{"termId" => 1, "termUrl" => "http://openshift.redhat.com/term1"}]
    json = {"unacknowledgedTerms" => terms}
    @streamline.expects(:http_post).once.yields(json).returns(terms)
    assert_equal terms, @streamline.establish_terms
    assert_equal 1, @streamline.terms.length
  end

  test "establish both terms" do
    terms = [{"termId" => 1, "termUrl" => "http://openshift.redhat.com/term1"},
             {"termId" => 2, "termUrl" => "http://www.redhat.com/term1"}]
    json = {"unacknowledgedTerms" => terms}
    @streamline.expects(:http_post).once.yields(json).returns(terms)
    assert_equal terms, @streamline.establish_terms
    assert_equal 2, @streamline.terms.length
  end
  
  test "establish both terms implicitly" do
    terms = [{"termId" => 1, "termUrl" => "http://openshift.redhat.com/term1"},
             {"termId" => 2, "termUrl" => "http://www.redhat.com/term1"}]
    json = {"unacknowledgedTerms" => terms}
    @streamline.expects(:http_post).once.yields(json).returns(terms)
    assert_equal terms, @streamline.terms
    assert_equal 2, @streamline.terms.length
  end

  test "accept terms" do
    @streamline.terms = [{"termId" => 'a', "termUrl" => 'url'},
             {"termId" => 'b', "termUrl" => 'url'}]
    json = {"term" => ['a', 'b']}
    @streamline.expects(:http_post).once.yields(json).returns(@streamline.terms)
    assert_equal true, @streamline.accept_terms
    assert_equal 0, @streamline.errors.size
  end

  test "accept terms with partial streamline result" do
    @streamline.terms = [{"termId" => 'a', "termUrl" => 'url'},
             {"termId" => 'b', "termUrl" => 'url'}]
    terms = ['a']
    json = {"term" => terms}
    @streamline.expects(:http_post).once.yields(json).returns(terms)
    assert_equal false, @streamline.accept_terms
    assert_equal 1, @streamline.errors.size
  end

  test "confirm simple email with emailAddress" do
    @streamline.email_address = 'foo@foo.com'
    @streamline.expects(:http_post).once.yields({'roles' => ['simple_authenticated'], 'emailAddress' => 'foo@foo.com'})
    assert @streamline.confirm_email('key')
    assert @streamline.errors.empty?
  end

  test "confirm simple email with login" do
    @streamline.email_address = 'foo@foo.com'
    @streamline.expects(:http_post).once.yields({'roles' => ['simple_authenticated'], 'login' => 'foo@foo.com'})
    assert @streamline.confirm_email('key')
    assert @streamline.errors.empty?
  end

  test "confirm simple email fails" do
    @streamline.email_address = 'foo@foo.com'
    @streamline.expects(:http_post).once.yields({'errors' => ['service_error']})
    assert !@streamline.confirm_email('key')
    assert_equal 1, @streamline.errors.size
    assert @streamline.errors[:base].first =~ /system error has occurred/
  end

  test "confirm simple email fails with empty json" do
    @streamline.email_address = 'foo@foo.com'
    @streamline.expects(:http_post).once.yields({}).returns
    assert !@streamline.confirm_email('key')
    assert_equal 1, @streamline.errors.size
    assert @streamline.errors[:base].first =~ /system error has occurred/
  end

  test "confirm simple email raise without email" do
    assert_raise(RuntimeError) { @streamline.confirm_email('key') }
  end
  test "confirm simple email take email as argument" do
    @streamline.expects(:http_post).once.yields({'roles' => ['simple_authenticated'], 'emailAddress' => 'foo@foo.com'})
    assert @streamline.confirm_email('key', 'foo@foo.com')
    assert @streamline.errors.empty?
  end

  test "authenticate success" do
    @streamline.expects(:http_post).once
    assert_equal true, @streamline.authenticate("test1", "test1")
    assert_equal 0, @streamline.errors.size
  end

  test "authenticate unknown user" do
    @streamline.expects(:http_post).once.yields({'roles' => ['foo'], 'username' => 'test1'})
    assert_equal true, @streamline.authenticate("test1", "test1")
    assert_equal 0, @streamline.errors.size

    assert_nil @streamline.streamline_type
    assert !@streamline.simple_user?
    assert !@streamline.full_user?
  end

  test "authenticate simple user" do
    @streamline.expects(:http_post).once.yields({'roles' => ['simple_authenticated'], 'username' => 'test1'})
    assert_equal true, @streamline.authenticate("test1", "test1")
    assert_equal 0, @streamline.errors.size

    assert_equal :simple, @streamline.streamline_type
    assert @streamline.simple_user?
    assert !@streamline.full_user?
  end

  test "authenticate full user" do
    @streamline.expects(:http_post).once.yields({'roles' => ['authenticated'], 'username' => 'test1'})
    assert_equal true, @streamline.authenticate("test1", "test1")
    assert_equal 0, @streamline.errors.size

    assert_equal :full, @streamline.streamline_type
    assert !@streamline.simple_user?
    assert @streamline.full_user?
  end

  test "authenticate fails" do
    @streamline.expects(:http_post).once.raises(AccessDeniedException.new)
    assert_equal false, @streamline.authenticate("test1", "test1")
    assert_equal 1, @streamline.errors.size
    assert_equal I18n.t(:login_error, :scope => :streamline), @streamline.errors[:base].first
  end

  test "authenticate fails with http not found" do
    @streamline.expects(:http_post).once.raises(Streamline::StreamlineException.new)
    assert_equal false, @streamline.authenticate("test1", "test1")
    assert_equal 1, @streamline.errors.size
    assert_equal I18n.t(:service_error, :scope => :streamline), @streamline.errors[:base].first
  end

  test "cookie initializes" do
    assert_equal "hi=value", Streamline::Cookie.new("hi", "value").to_s
  end

  test "rack should not escape rh_sso" do
    headers = {}
    Rack::Utils.set_cookie_header!(headers, 'rh_sso', '1+2')
    assert_equal 'rh_sso=1+2', headers['Set-Cookie']
  end

  test "rack should escape all other cookies" do
    headers = {}
    Rack::Utils.set_cookie_header!(headers, 'foo', '1+2')
    assert_equal 'foo=1%2B2', headers['Set-Cookie']
  end
end
