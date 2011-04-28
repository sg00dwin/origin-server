require 'pp'

class Access::AccessRequestController < ApplicationController
  def new
    Rails.logger.debug "Checking login status"
    login = session[:login]
    if login
      @user = session_user
      @user.refresh_roles
      if @user.has_requested?(access_type)
        render :already_requested and return
      elsif @user.has_access?(access_type)
        redirect_to getting_started_path and return
      end
      @user.establish_terms      
      setup_new_model
      yield if block_given?
    else
      Rails.logger.debug "User is not logged in - rerouting to login / register"
      session[:login_workflow] = new_path
      redirect_to login_path, :notice => flash[:notice] ? flash[:notice] : "You'll need to login / register before asking for access"
    end
  end

  def create
    Rails.logger.debug "Checking login status"
    login = session[:login]
    if login
      Rails.logger.debug "User is logged in"
      setup_create_model(params)
      @user = session_user
      @user.establish_terms

      # Run validations
      render :new and return if !@access.valid?

      # Accept the subscription terms
      Rails.logger.debug "Requesting access #{CloudAccess.access_name(access_type)} for user #{@user.pretty_inspect}"
      @user.accept_terms unless @user.terms.empty?

      # Now request access to the developer preview
      execute_request_access
    else
      Rails.logger.debug "User is not logged in - rerouting to login / register"
      session[:login_workflow] = new_path
      redirect_to login_path and return
    end
  end
  
  def execute_request_access
    # Now request access to the developer preview
    request_access if @user.errors.empty?
    if @user.errors.length > 0
      @access.errors.update(@user.errors)
      render :new and return
    else
      @user.refresh_roles(true)
      yield if block_given?
    end
  end

end
