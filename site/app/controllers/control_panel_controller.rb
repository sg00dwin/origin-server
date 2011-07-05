class ControlPanelController < ApplicationController
  before_filter :deny_access, :require_login

  def index
    #@userinfo = ExpressUserinfo.new(:rhlogin => session[:login])
    #@userinfo.establish unless @userinfo.nil?
    #if @userinfo.namespace.nil? or @userinfo.namespace.empty?
      #@domain = ExpressDomain.new
      #@info = 'No domain yet, show create form'
    #else
      #@domain = ExpressDomain.new
      #@info = 'Has a domain - show edit form'
    #end
    @domain = ExpressDomain.new
  end

end
