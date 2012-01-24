module Cloud
  module Sdk
    class UserModel < Model
      
      def initialize()
        super()
      end
      
      def self.find(login, id)
        id_var = @primary_key || "uuid"        
        data = DataStore.instance.find(self.name,login,id)
        return nil if data.to_s.strip.length ==0
        
        obj = self.new.from_json(data.values[0])
        obj.instance_variable_set("@#{id_var}", data.keys[0])
        obj.reset_state
        obj
      end
      
      def self.find_all(login)
        id_var = @primary_key || "uuid"        
        data_list = DataStore.instance.find_all(self.name,login)
        return [] if data_list.to_s.strip.length ==0

        data_list.map! do |data|
          obj = self.new.from_json(data.values[0])
          obj.instance_variable_set("@#{id_var}", data.keys[0])
          obj.reset_state
          obj
        end
      end
      
      def delete(login)
        id_var = self.class.pk || "uuid"
        DataStore.instance.delete(self.class.name, login, instance_variable_get("@#{id_var}"))
      end
      
      def save(login)
        id_var = self.class.pk || "uuid"
        was_persisted = @persisted
        @previously_changed = changes
        @changed_attributes.clear
        @new_record = false
        @persisted = true
        @deleted = false
        if was_persisted
          DataStore.instance.save(self.class.name, login, instance_variable_get("@#{id_var}"), self.attributes)
        else
          DataStore.instance.create(self.class.name, login, instance_variable_get("@#{id_var}"), self.attributes)
        end
        self
      end
      
      protected

    end
  end
end
