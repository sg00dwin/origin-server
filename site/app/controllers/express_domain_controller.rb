class ExpressDomainController < ApplicationController
  before_filter :require_login

  def create
    # Get only relevant parameters
    domain_params = params[:express_domain]
    domain_params[:rhlogin] = session[:login]
    @domain = ExpressDomain.new(domain_params)
    if @domain.valid?
      begin
        @domain.create do |json_response|
          result = ActiveSupport::JSON.decode(json_response["data"])
          Rails.logger.debug "Domain api result: #{result.inspect}"
          # check that we have expected result
          unless result["uuid"].nil?
            @message = I18n.t('express_api.messages.domain_created')
            @message_type = :success
          else
            # unexpected result
            @message = json_response["messages"].empty? ? I18n.t(:unknown) : json_response["messages"]
            @message_type = :error
          end
        end # end domain creation block
      rescue Exception
        # Exception messages are recorded in the error hash in ExpressApi
        @message = @domain.errors.full_messages.join('<br/>')
        @message_type = :error
      end
    else
      # display validation errors
      @message = @domain.errors.full_messages.join('<br/>')
      @message_type = :error
    end
    
    # respond based on requested format
    respond_to do |format|
      format.html {flash[@message_type] = @message; redirect_to getting_started_express_path}
      format.js
    end
  end
  
  #def update; end
  
end
