module Account
  module Help
    extend ActiveSupport::Concern

    def help
      @topten = FaqItem.topten
      @user = User.find :one, :as => current_user
      @user_on_basic_plan = user_on_basic_plan?
      @post = SupportContact.new(:user => @user)
    end

    def contact_support
      #@contact = SupportContact.new(params[:support_contact])
      #AccountSupportContactMailer.contact_email(@contact).deliver
      redirect_to( { :action => 'help' }, :flash => {:success => 'Account Support email has been sent.'} )
    end

    # TODO:  Should this be a separate controller??
    def faqs
      render :json => FaqItem.all
    end
  end
end
