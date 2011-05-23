class CloudAccess
  EXPRESS = 1
  FLEX = 2
  POWER = 3
  
  IDS = [EXPRESS, FLEX, POWER]
  
  EXPRESS_NAME = 'express'
  FLEX_NAME = 'flex'
  POWER_NAME = 'power'
  
  NAME_TO_ID = {EXPRESS_NAME => EXPRESS, FLEX_NAME => FLEX, POWER_NAME => POWER}
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
