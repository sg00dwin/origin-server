class CloudAccess
  EXPRESS = 1
  FLEX = 2
  POWER = 3

  def req_role(solution)
    "cloud_access_request_#{solution}"
  end

  def auth_role(solution)
    "cloud_access_#{solution}"
  end
end
