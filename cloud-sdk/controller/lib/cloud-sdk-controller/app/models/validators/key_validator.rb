class KeyValidator < ActiveModel::Validator
  
  def validate(record)
    # do my validations on the record and add errors if necessary
    record.errors[:base] << "This is some custom error message"
    record.errors[:first_name] << "This is some complex validation"
  end
  
  validates_each :ssh_keys do |record, attribute, val|
    val.each do |key_name, key_info|
      if !(key_name =~ /\A[A-Za-z0-9]+\z/)
        record.errors.add attribute, {:message => "Invalid key name: #{key_name}", :exit_code => 117}
      end
      if !(key_info['type'] =~ /^(ssh-rsa|ssh-dss)$/)
        record.errors.add attribute, {:message => "Invalid key type: #{key_info['type']}", :exit_code => 116}
      end
      if !(key_info['key'] =~ /\A[A-Za-z0-9\+\/=]+\z/)
        record.errors.add attribute, {:message => "Invalid ssh key: #{key_info['key']}", :exit_code => 108}
      end
    end if val
  end
end