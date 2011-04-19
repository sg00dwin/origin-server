class Access::FlexRequest < Access::AccessRequest  

  attr_accessor :ec2_account_number
  
  validates_format_of :ec2_account_number, :with => /\d{4}-\d{4}-\d{4}/, :message => 'Account numbers are a 12 digit number separated by - Ex: 1234-1234-1234'

end
