class AccountController < ApplicationController
  include Console::Rescue

  layout :account_layout

  def account_layout
    ['new','create','complete','create_external'].include?(action_name) ? 'simple' : 'console'
  end

  before_filter :require_login, :only => :show
  protect_from_forgery :except => :create_external

  include Account::Creation
  include Account::ExternalCreation
  include Rails.configuration.aria_enabled ? Account::ExtendedDashboard : Account::Dashboard
end
