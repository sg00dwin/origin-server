class AccountController < ApplicationController
  include Console::Rescue

  layout :account_layout

  def account_layout
    ['new','create','complete','create_external'].include?(action_name) ? 'simple' : 'console'
  end

  before_filter :require_login, :only => [:show, :help]
  protect_from_forgery :except => :create_external

  include Account::Creation
  include Account::ExternalCreation
  include Account::ExtendedDashboard

  def help
    @topten = FaqItem.topten
    @user = User.find :one, :as => current_user
    @user_on_basic_plan = user_on_basic_plan?
  end

  # TODO:  Should this be a separate controller??
  def faqs
    render :json => FaqItem.all
  end
end
