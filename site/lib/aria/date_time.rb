module Aria
  module DateTime
    def self.today
      (Date.today + get_offset.hours).to_date
    end

    def self.now
      Time.now + get_offset.hours
    end

    def self.virtual_time?
      get_offset > 0
    end

    private
      def self.get_offset
        return 0 if Rails.env.production?
        Aria.cached.get_virtual_datetime.current_offset_hours
      end
  end
end
