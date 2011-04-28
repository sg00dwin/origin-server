require 'pp'
require 'json'

class TermsController < ApplicationController

  def new
    new_terms
  end

  def acceptance_terms
    new_terms
  end
  
  def new_terms
    @user = session_user
    if @user
      @user.establish_terms
      if @user.terms.length > 0
        @term = Term.new
      else
        #TODO would like this to show the terms they have already accepted
        redirect_to legal_site_terms_path and return
      end
    else
      Rails.logger.debug "User is not logged in - rerouting to login / register"
      session[:login_workflow] = new_terms_path
      redirect_to login_path
    end
  end

  def create
    @user = session_user
    @term = Term.new
    if @user
      logger.debug "Accepting terms for user #{@user.pretty_inspect}"
      @user.accept_terms unless @user.terms.empty?
      
      if @user.errors.length > 0
        logger.debug "Found errors, updating terms object with #{@user.errors}"
        @term.errors.update(@user.errors)
        render :new and return
      else
        # This is the key to get past terms checking in application controller
        session[:login] = @user.rhlogin
      end

      if workflow_redirect
        return
      else
        redirect_to root_path and return
      end
    else
      Rails.logger.debug "User is not logged in - rerouting to login / register"
      session[:login_workflow] = new_terms_path
      redirect_to login_path
    end
  end

end
