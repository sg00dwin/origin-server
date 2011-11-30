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
  end
  
  def register_namespace(namespace)
  end
  
  def deregister_namespace(namespace)
  end
  
  def publish
  end
  
  def close
  end
end