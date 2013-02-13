class SupportContact
  include ActiveModel::Conversion
  include ActiveModel::Serialization
  extend ActiveModel::Naming
  
  attr_accessor :subject, :body, :user, :from
  
  def initialize(params)
    Rails.logger.debug "params: #{params}"
    @subject = params[:subject]
    @body    = params[:body]
    @user    = params[:user]
    @from    = params[:from]
  end
  
  def persisted?
    false
  end
end