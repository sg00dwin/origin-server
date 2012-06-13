require File.expand_path('../../test_helper', __FILE__)

class FakeBeforeFilter < ApplicationController
  before_filter :require_login, :only => [:show]

  def index
    render :nothing => true
  end

  def show
    render :nothing => true
  end
end

class FakeBeforeFilterTest < ActionController::TestCase
  include ActionView::Helpers::UrlHelper

  def setup
    # Replicate the routes we need
    RedHatCloud::Application.routes.draw do
      resources :fake_before_filter
      resources :login

      resource :terms,
        :as => "terms",
        :controller => "terms",
        :path_names => { :new => 'accept' },
        :only => [:new, :create]
    end
  end

  def teardown
    RedHatCloud::Application.reload_routes!
  end

  def make_request
    get(:show, {:id => 1} ) # Need a fake show request
  end

  def login
    setup_user
    @controller.stubs(:current_user).returns(@user)
    @controller.expects(:user_signed_in?).at_least_once.returns(true)
  end

  def accept_terms
    @user.accept_terms
  end

  test 'public page' do
    get :index
    assert_response :success
  end

  test 'not logged in' do
    make_request
    assert_redirected_to  login_path(:redirectUrl => '/fake_before_filter/1')
  end

  test 'logged in but not accepted terms' do
    login
    @user.expects(:terms).at_least_once.returns([1,2])
    make_request

    assert_redirected_to  new_terms_path
  end

  test 'logged in with terms, but no access' do
    login
    accept_terms

    @user.stubs(:entitled?).returns(false)
    @user.stubs(:waiting_for_entitle?).returns(true)

    make_request

    assert_response :success
    assert_not_nil flash[:notice]
    assert_match(/access setup/, flash[:notice])
  end

  test 'fully logged in' do
    login
    accept_terms

    @user.stubs(:entitled?).returns(true)

    make_request
    assert_response :success
    assert_nil flash[:notice]
  end

  #  test 'tickets to not match' do
  #    flunk
  #  end

  #  test 'current ticket is expired' do
  #    flunk
  #  end
end
