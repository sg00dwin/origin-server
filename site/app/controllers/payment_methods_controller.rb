class PaymentMethodsController < ApplicationController
  layout 'site'

  before_filter :authenticate_user!

  def edit
    @user = current_user.extend Aria::User
    @payment_method = @user.payment_method
    @previous_payment_method = @payment_method.dup
    @payment_method.cc_no = nil
    @payment_method.mode = Aria::DirectPost.get_or_create(post_name, url_for(:action => :direct_update))
    @payment_method.session_id = @user.create_session
  end

  def direct_update
    if serve_direct?
      render :notify_parent, :layout => 'bare'
    else
      redirect_to next_path and return if @errors.empty?
      redirect_to url_for(:action => :edit), :flash => {:error => to_flash(@errors)}
    end
  end

  def delete
  end

  def destroy
  end

  protected
    # Allow subclasses to override edit redirection behavior
    def next_path
      account_path
    end
    def post_name
      'account'
    end

    def serve_direct?
      logger.debug params.inspect
      @errors = (params[:error_messages] || {}).values.map{ |v| v['error_key'] }.uniq.map do |s|
        I18n.t(s, :scope => [:aria, :direct_post], :default => s)
      end
      @user = current_user.extend Aria::User
      unless @user.has_valid_payment_method?
        @errors << I18n.t(:unknown, :scope => [:aria, :direct_post])
      end
      params[:params] && params[:params][:params] == 'serve_direct'
    end

    def to_flash(errors)
      return errors.first if errors.length == 1
      "Your payment information could not be processed.<ul><li>#{errors.join("</li><li>")}</li></ul>".html_safe
    end

    def text
      TextHelper.instance
    end
    class TextHelper
      include Singleton
      include ActionView::Helpers::TextHelper
    end
end
