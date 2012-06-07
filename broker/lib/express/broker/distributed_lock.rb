module Express
  module Broker
    class DistributedLock
      def initialize()
      end

      def self.obtain_lock(type, owner_id, allow_owner_multiple_access=false)
        return StickShift::DataStore.instance.obtain_distributed_lock(type, owner_id, allow_owner_multiple_access)
      end

      def self.release_lock(type, owner_id=nil)
        StickShift::DataStore.instance.release_distributed_lock(type, owner_id)
      end
    end
  end
end
