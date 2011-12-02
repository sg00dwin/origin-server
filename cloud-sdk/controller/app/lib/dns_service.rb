class DNSException < Cloud::Sdk::CdkException
  def initialize(msg=nil,code=nil)
    super(msg,code)
  end
end

class DNSNotFoundException < DNSException; 
  def initialize(msg=nil,code=nil)
    super(msg,code)
  end
end

class DnsService
  def initialize
  end
  
  def namespace_available?(namespace)
    return true
  end
  
  def register_namespace(namespace)
  end
  
  def deregister_namespace(namespace)
  end
  
  def register_application(app_name, namespace, user_name)
  end
  
  def deregister_application(app_name, namespace, user_name)
  end
  
  def publish
  end
  
  def close
  end
end