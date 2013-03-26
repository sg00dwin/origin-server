module Aria
  class UsageLineItem < LineItem
    define_attribute_method :units

    def usage?
      true
    end

    def name
      if service
        service.service_desc
      else
        case usage_type_description
        when /Small Gear/ then 'Gear: Small'
        when /Medium Gear/ then 'Gear: Medium'
        when /Silver Storage/ then 'Storage: Additional Gear'
        else usage_type_description
        end
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
      if service
        code = service.client_coa_code
        if code.starts_with? 'usage_gear_'
          "gear-hour"
        elsif code == 'usage_storage_gear'
          "gigabyte-hour"
        else
          "unit"
        end
      else
        case usage_type_description
        when /storage/
          "gigabyte-hour"
        else
          "gear-hour"
        end
      end
    rescue => e
      Rails.logger.error "#{e.message} (#{e.class})\n  #{e.backtrace.join("\n  ")}"
      '<unknown>'
    end

    def free_units
      service.plan_service_rates.each do |r| 
        to_unit = r.to_unit
        return to_unit if r.rate_per_unit == 0.0 && to_unit && to_unit > 0
      end if service
      false
    end

    def usage_type_description
      attributes['usage_type_description'] || attributes['service_name']
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
        @service ||= Aria.cached.get_client_plans_all.find{ |s| s.plan_no.to_s == plan_no.to_s }.plan_services.find{ |s| s.usage_type == usage_type_no }
      end
  end
end
