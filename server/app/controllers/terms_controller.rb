require 'pp'
require 'json'

class TermsController < ApplicationController

  def new
    @user = session_user
    if @user
      @user.establish_terms
      if @user.site_terms.length > 0
        @term = Term.new
      else
        render :site_terms and return
      end
    else
      Rails.logger.debug "User is not logged in - rerouting to login / register"
      session[:workflow] = new_terms_path
      redirect_to login_path
    end
  end

  def create
    @user = session_user
    @term = Term.new
    if @user
      logger.debug "Accepting terms for user #{@user.pretty_inspect}"
      @user.accept_site_terms unless @user.site_terms.empty?

      logger.debug "Errors: #{@user.errors}"
      if @user.errors.length > 0
        logger.debug "Found errors, updating terms object with #{@user.errors}"
        @term.errors.update(@user.errors)
        render :new and return
      else
        # This is the key to get past terms checking in application controller
        session[:login] = @user.rhlogin
      end

      workflow = session[:workflow]
      if (workflow)
        session[:workflow] = nil
        redirect_to workflow and return
      else
        redirect_to root_path and return
      end
    else
      Rails.logger.debug "User is not logged in - rerouting to login / register"
      session[:workflow] = new_terms_path
      redirect_to login_path
    end
  end

  def acceptance_terms
    @user = session_user
    if @user
      @user.establish_terms
      if @user.site_terms.length > 0
        @term = Term.new
      else
        render :site_terms and return
      end
    else
      Rails.logger.debug "User is not logged in - rerouting to login / register"
      session[:workflow] = new_terms_path
      redirect_to login_path
    end
  end

  def site_terms; end

  def services_agreement; end

end
