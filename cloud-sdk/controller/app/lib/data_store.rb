class DataStore
  def self.find(obj_type, user_id, id)
    print "DataStore.find(#{obj_type}, #{user_id}, #{id})\n\n"
  end
  
  def self.find_all(obj_type, user_id)
    print "DataStore.find_all(#{obj_type}, #{user_id})\n\n"
  end
  
  def self.save(obj_type, user_id, id, serialized_obj)
    print "DataStore.save(#{obj_type}, #{user_id}, #{id}, #{serialized_obj})\n\n"    
  end
  
  def self.delete(obj_type, user_id, id)
    print "DataStore.delete(#{obj_type}, #{user_id}, #{id})\n\n"        
  end
end