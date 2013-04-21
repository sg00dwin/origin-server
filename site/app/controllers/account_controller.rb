class AccountController < ApplicationController
  include Console::Rescue

  layout :account_layout

  def account_layout
    ['new','create','complete','create_external'].include?(action_name) ? 'simple' : 'console'
  end

  protect_from_forgery :except => :create_external
  before_filter :require_login, :only => [:show, :welcome, :help, :contact_support]

  include Account::Creation
  include Account::ExternalCreation
  include Account::ExtendedDashboard
  include Account::Help

  protected
    helper_method :active_tab
    def active_tab
      :account
    end
end
