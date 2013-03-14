module Aria
  class UsageLineItem < LineItem
    define_attribute_method :units

    def recurring?
      false
    end
    def usage?
      true
    end
    def tax?
      false
    end

    def name
      case usage_type_description
      when 'Small Gear' then 'Gear: Small'
      when 'Medium Gear' then 'Gear: Medium'
      when 'MegaShift Storage' then 'Storage: Additional Gear'
      else usage_type_description
      end
    end

    def rate
      pre_rated_rate
    end

    #
    # The total amount associated with this line item.
    #
    def total_cost
      @total_cost ||= units * pre_rated_rate
    end

    #
    # The string label that applies to this usage line item: e.g. 'hours'
    #
    def units_label
      case service.client_coa_code
      when 'smallusage', 'mediumusage', 'largeusage'
        "gear-hour"
      when 'megastorage'
        "gigabyte-hour"
      else
        "unit"
      end
      #service.usage_unit_label 
    rescue => e
      Rails.logger.error "#{e.message} (#{e.class})\n  #{e.backtrace.join("\n  ")}"
      '<unknown>'
    end

    #
    # Given a range of usage, calculate a set of usage line items for
    # that usage period.
    #
    def self.for_usage(usage, plan_no)
      usage.inject({}) do |h, u|
        if item = h[u.usage_type_no]
          item << u
        else
          h[u.usage_type_no] = new(u, plan_no)
        end
        h
      end.values
    end

    #
    # Combine an Aria usage record into this line item.  Does not
    # validate that the usage record is related
    #
    def <<(other)
      @total_cost = total_cost + other.units * other.pre_rated_rate
      self.units = self.units + other.units
      self.recorded_units = nil
      self.specific_record_charge_amount = nil
    end

    protected
      define_attribute_methods [:usage_type_no,
                                :usage_type_description,
                                :pre_rated_rate,
                                :recorded_units,
                                :units_description,
                                :specific_record_charge_amount,
                                :billable_account_no]

      def service
        @service ||= Aria.cached.get_client_plan_services(plan_no).find{ |s| s.usage_type == usage_type_no }
      end
  end
end
