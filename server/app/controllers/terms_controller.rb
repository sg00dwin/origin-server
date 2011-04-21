require 'pp'
require 'json'

class TermsController < ApplicationController
  
  def new
    @user = session_user
    if @user
      @term = Term.new
    else
      Rails.logger.debug "User is not logged in - rerouting to login / register"
      session[:workflow] = new_path
      redirect_to login_path
    end
  end
  
  def create    
    @user = session_user
    if @user
      term = params[:term]
      @term = Term.new(term ? term : {})
      @user.establish_terms
      if !@term.valid?
        render :new and return
      else
        if @user.site_terms.length > 0
          @user.accept_terms(@term.accepted_terms_list, @user.site_terms)
        end
        if @user.errors.length > 0
          @term.errors.update(@user.errors)
          render :new and return
        else
          # This is the key to get past terms checking in application controller
          session[:login] = @user.rhlogin
        end
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
      session[:workflow] = new_path
      redirect_to login_path
    end
  end
  
  def site_terms; end
  def service_terms; end
  
end
