require 'pp'

class Access::AccessRequestController < ApplicationController
  def new
    Rails.logger.debug "Checking login status"
    login = session[:login]
    if login
      setup_new_model
      @user = WebUser.find_by_ticket(session[:ticket])
      if @user
        setup_user_session(@user)
        @user.establish_terms
      else
        #
      end
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
      @user = WebUser.find_by_ticket(session[:ticket])
      if @user
        setup_user_session(@user)
        @user.establish_terms
      else
        #
      end
      if !@access.valid?
        render :new and return
      else
        Rails.logger.debug "Requesting access #{access_type} for user #{@user}"
        if @user.terms.length > 0
          @user.accept_terms(@access.accepted_terms_list)
        end
        if @user.errors.length == 0
          request_access
        end
        if @user.errors.length > 0
          @access.errors.update(@user.errors)          
          render :new and return
        end
      end
    else
      Rails.logger.debug "User is not logged in - rerouting to login / register"
      session[:workflow] = new_path
      redirect_to login_path
    end
  end
  
  
end