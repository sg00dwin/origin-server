require File.expand_path('../../test_helper', __FILE__)

class ConsoleControllerTest < ActionController::TestCase

  setup :with_unique_user

  test 'should raise if no domain' do
    assert_raise(ActiveResource::ResourceNotFound) { @controller.user_default_domain }
  end

  test 'should retrieve and set domain onto session' do
    d = with_domain
    assert_nil session[:domain]
    assert domain = @controller.user_default_domain
    assert_equal d.name, session[:domain]
    assert_same domain, @controller.user_default_domain
    assert_equal d.name, session[:domain]
  end

  test 'should retrieve domain from session cache' do
    Domain.expects(:find).never

    session[:domain] = 'foo'
    assert domain = @controller.user_default_domain
    assert_equal 'foo', session[:domain]
    assert_equal 'foo', domain.name
    assert_same domain, @controller.user_default_domain
  end

  test 'should register domain sweeper listener and filter' do
    RestApi::Base.observers.include? DomainSessionSweeper
    assert @controller._process_action_callbacks.map(&:raw_filter).any?{ |f| f == DomainSessionSweeper }

    DomainSessionSweeper.domain_changes = true
    DomainSessionSweeper.before(@controller)
    assert !DomainSessionSweeper.domain_changes?

    DomainSessionSweeper.domain_changes = true
    session[:domain] = 'foo'
    DomainSessionSweeper.after(@controller)
    assert_nil session[:domain]
  end
end
