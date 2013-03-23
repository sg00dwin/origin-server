module Aria
  class UsageLineItem < LineItem
    define_attribute_method :units

    def usage?
      true
    end

    def name
      case usage_type_description
      when /Small Gear/ then 'Gear: Small'
      when /Medium Gear/ then 'Gear: Medium'
      when /MegaShift Storage/ then 'Storage: Additional Gear'
      else usage_type_description
      end
    end

    def date
      date_range_start
    end

    def rate
      attributes['pre_rated_rate'] || attributes['rate_per_unit']
    end
    alias_method :pre_rated_rate, :rate
    alias_method :rate_per_unit, :rate

    #
    # The total amount associated with this line item.
    #
    def total_cost
      @total_cost ||= units * rate
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

    def usage_type_description
      attributes['usage_type_description'] || attributes['service_name']
    end

    #
    # Combine an Aria usage record into this line item.  Does not
    # validate that the usage record is related
    #
    # "other" must be an Aria usage_history record item.
    #
    def <<(other)
      @total_cost = total_cost + other.units * other.pre_rated_rate
      self.units = self.units + other.units
      self.recorded_units = nil
      self.specific_record_charge_amount = nil
    end

    def self.type_info (items)
      Hash[
        items
          .uniq(&:name)
          .sort_by(&Aria::LineItem.plan_sort)
          .each_with_index.map { |item,index| 
            [
              item.name,
              OpenStruct.new({:units => item.units_label, :class_name => "type-#{index+1}" })
            ]
          }
      ]
    end

    protected
      define_attribute_methods [:usage_type_no,
                                :usage_type_description,
                                :recorded_units,
                                :units_description,
                                :specific_record_charge_amount,
                                :billable_account_no,
                                :date_range_start]

      def service
        @service ||= Aria.cached.get_client_plan_services(plan_no).find{ |s| s.usage_type == usage_type_no }
      end
  end
end
