class AccountController < ApplicationController

  layout 'simple'

  before_filter :require_login, :only => :show
  protect_from_forgery :except => :create_external

  include Account::Creation
  include Account::ExternalCreation
  include Rails.configuration.aria_enabled ? Account::ExtendedDashboard : Account::Dashboard
end
