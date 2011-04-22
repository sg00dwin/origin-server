require 'pp'

class Access::AccessRequestController < ApplicationController
  def new
    Rails.logger.debug "Checking login status"
    login = session[:login]
    if login
      @user = session_user
      if @user.has_requested?(access_type)
        render :already_requested and return
      elsif @user.has_access?(access_type)
        redirect_to getting_started_path and return
      end
      @user.establish_terms
      @user.refresh_roles
      setup_new_model
    else
      Rails.logger.debug "User is not logged in - rerouting to login / register"
      session[:workflow] = new_path
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
      if !@access.valid?
        render :new and return
      else
        Rails.logger.debug "Requesting access #{CloudAccess.access_name(access_type)} for user #{@user}"
        if @user.terms.length > 0
          @user.accept_subscription_terms(@access.accepted_terms_list)
        end
        if @user.errors.length == 0
          request_access
        end
        if @user.errors.length > 0
          @access.errors.update(@user.errors)
          render :new and return
        else
          @user.refresh_roles(true)
        end
      end
    else
      Rails.logger.debug "User is not logged in - rerouting to login / register"
      session[:workflow] = new_path
      redirect_to login_path
    end
  end

end
