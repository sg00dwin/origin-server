class AuthServiceException < Cloud::Sdk::CdkException
  def initialize(msg=nil,code=nil)
    super(msg,code)
  end
end

class AuthService
  def login(login, password)
    return login
  end
end