class ExpressSshKeysController < ApplicationController
  before_filter :require_login

  def create
    @express_ssh_key = ExpressSshKey.new params[:express_ssh_key]
    @express_ssh_key.rhlogin = session[:login]
    @express_ssh_key.ticket = session[:ticket]

    @userinfo = ExpressUserinfo.new :rhlogin => session[:login],
                                    :ticket => session[:ticket]
    @userinfo.establish
    @express_ssh_key.namespace = @userinfo.namespace

    if @express_ssh_key.mode == "update"
      @express_ssh_key.update

      if @express_ssh_key.errors.empty? and @express_ssh_key.primary?
        @userinfo.ssh_key = @express_ssh_key.public_key
        @userinfo.key_type = @express_ssh_key.type
      end
    else
      @express_ssh_key.create
    end

    @ssh_keys = @userinfo.ssh_keys
    @primary_ssh_key = default_key(@ssh_keys)
  end

  def destroy
    @express_ssh_key = ExpressSshKey.new params[:express_ssh_key]
    @express_ssh_key.rhlogin = session[:login]
    @express_ssh_key.ticket = session[:ticket]
    @express_ssh_key.destroy

    @userinfo = ExpressUserinfo.new :rhlogin => session[:login],
                                    :ticket => session[:ticket]
    @userinfo.establish
    @ssh_keys = @userinfo.ssh_keys
    @primary_ssh_key = default_key(@ssh_keys)
  end

  private

  def default_key(keys)
    default = nil
    keys.each do |key|
      if key.primary?
        default = key
      end
    end

    default || ExpressSshKey.new(:primary => true)
  end
end
