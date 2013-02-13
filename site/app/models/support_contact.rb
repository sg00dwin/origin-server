class SupportContact
  include ActiveModel::Conversion
  include ActiveModel::Serialization
  extend ActiveModel::Naming
  
  attr_accessor :subject, :body, :user, :from
  
  def initialize(user)
    @user = user
  end
  
  def persisted?
    false
  end
end