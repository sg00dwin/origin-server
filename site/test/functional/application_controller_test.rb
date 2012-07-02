require File.expand_path('../../test_helper', __FILE__)

class ApplicationControllerTest < ActionController::TestCase

  def with_custom_config(options={}, integrated=Rails.configuration.integrated, &block)
    rconf = Rails.configuration
    streamline = rconf.streamline
    old_integrated = rconf.integrated
    old_streamline = streamline.clone

    rconf.integrated = integrated
    streamline.merge!(options)

    yield

    rconf.integrated = old_integrated
    rconf.streamline = old_streamline
  end

  test 'user_from_session handles exceptions' do
    @request.cookies['rh_sso'] = "im_a_bad_cookie"
    WebUser.expects(:find_by_ticket).raises(AccessDeniedException)
    @controller.send('user_from_session')
  end

  test 'user_to_session stores user' do
    attrs = {:ticket => 'ticket', :rhlogin => 'login', :streamline_type => :simple}
    user = WebUser.new(attrs)

    attrs[:login] = attrs.delete(:rhlogin) # different names
    attrs.merge!(session)

    @controller.send('user_to_session', user)

    assert (session[:ticket_verified] - Time.now.to_i) < 100
    attrs[:ticket_verified] = session[:ticket_verified]

    assert_equal attrs.with_indifferent_access, session.to_hash.with_indifferent_access
  end

  test 'user_from_session restores simple user' do
    attrs = {:ticket => 'ticket', :login => 'login', :streamline_type => :simple}
    attrs.each_pair {|k,v| @request.session[k] = v }
    user = @controller.send('user_from_session')
    attrs[:rhlogin] = attrs.delete(:login) # different names
    attrs.each_pair {|k,v| assert_equal v, user.send(k) }
    assert user.simple_user?
  end

  test 'user_from_session restores full user' do
    attrs = {:ticket => 'ticket', :login => 'login', :streamline_type => :full}
    attrs.each_pair {|k,v| @request.session[k] = v }
    user = @controller.send('user_from_session')
    attrs[:rhlogin] = attrs.delete(:login) # different names
    attrs.each_pair {|k,v| assert_equal v, user.send(k) }
    assert !user.simple_user?
  end
  
  test 'cookie domain can be loosely defined' do
    with_custom_config({:cookie_domain => 'test.com'}, false) do
      assert_equal '.test.com', @controller.send(:sso_cookie_domain)
    end
  end

  test 'cookie domain local is nil, can depend on request' do
    @request.host = 'a.test.domain.com'
    with_custom_config({:cookie_domain => :current}, false) do
      assert_nil @controller.send(:sso_cookie_domain)
    end
  end

  test 'integrated default domain_cookie_opts' do
    with_custom_config({:cookie_domain => nil}, false) do
      assert_equal '.redhat.com', @controller.send(:sso_cookie_domain)
    end
  end

  test 'create server relative uri' do
    {
      '' => nil,
      ' ' => nil,
      '/' => nil,
      '/?' => nil,
      '/?' => nil,
      '/foo?' => '/foo',
      '/foo?a=b' => '/foo?a=b',
      'http://www.google.com/foo?a=b' => '/foo?a=b',
    }.each_pair{ |k,v| assert_equal v, @controller.server_relative_uri(k) }
  end
end
