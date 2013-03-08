module Aria
  class UsageLineItem < LineItem

    protected
      define_attribute_methods [:usage_type_no,
                                :usage_type_description,
                                :pre_rated_rate,
                                :recorded_units,
                                :units_description,
                                :billable_account_no]

      def service
        @service ||= Aria.cached.get_client_plan_services(plan_no).find{ |s| s.usage_type == usage_type_no }
      end

    public
    alias_method :name, :usage_type_description
    define_attribute_method :units

    def recurring?
      false
    end
    def usage?
      true
    end
    def taxable?
      false
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
      service.usage_unit_label 
    rescue => e
      Rails.logger.error "#{e.message} (#{e.class})\n  #{e.backtrace.join("\n  ")}"
      '<unknown>'
    end

    def summary
      "#{units} per #{units_label}"
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
      self.units += other.units
      @total_cost = total_cost + other.units * other.pre_rated_rate
    end


  end
end
