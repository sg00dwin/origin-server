class CloudAccess
  EXPRESS = 1
  
  IDS = [EXPRESS]
  
  EXPRESS_NAME = 'express'
  
  NAME_TO_ID = {EXPRESS_NAME => EXPRESS}
  ID_TO_NAME = NAME_TO_ID.invert
  
  def self.access_id(name)
    NAME_TO_ID[name]
  end
  
  def self.access_name(id)
    ID_TO_NAME[id]
  end

  def self.req_role(solution)
    "cloud_access_request_#{solution}"
  end

  def self.auth_role(solution)
    "cloud_access_#{solution}"
  end
end
