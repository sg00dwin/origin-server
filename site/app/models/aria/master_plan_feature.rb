module Aria
  class MasterPlanFeature
    attr_accessor :name, :value, :type, :rank

    # We'll throw this when someone tries to compare different features.
    ComparisonError = Class.new(Aria::Error)

    # We'll throw this when we can't parse a feature definition
    MalformedFeatureError = Class.new(Aria::Error)

    def initialize(attributes={})
      attributes[:value] ||= ''
      attributes[:count] ||= 0
      attributes[:type] ||= 'text'
      attributes[:rank] ||= 0

      @count = attributes[:count].to_i

      attributes.each do |name,value|
        unless name == :count
          send("#{name}=", value)
        end
      end
    end

    def count
      (type == 'numeric') ? @count : nil
    end

    def not_available?
      (type == 'text' and value == '') or (type == 'numeric' and count == 0)
    end

    def <=>(other)
      raise ComparisonError.new('Only identically named features can be compared.') unless name == other.name
      return value <=> other.value if rank == other.rank and type == 'numeric'
      rank <=> other.rank
    end

    def self.from_description(plan_description)
      # Unpack the plan description. It follows this general format:
      #
      # <free-form text>\n
      # \n
      # Features:\n
      # * <key>: <value> <ranking>
      # * ...
      feature_list = []

      features = plan_description.each_line.select{ |line| line !~ /^\s*$/ }.map(&:chomp).split{ |s| s =~ /^\s*Features:/ }[1]
      (features || []).map do |feature|
        match, name, data, ranking = /^\* ([^\:]+)\: ([^\*]+) *(\**)$/.match(feature).to_a
        type = 'text'
        rank = ranking.nil? ? 0 : ranking.length
        count = 0
        if data =~ /^\d+$/
          count = data
          type  = 'numeric'
        end
        if (name.nil? or name =~ /^\s*$/ or data.nil? or data =~ /^\s*$/)
          raise MalformedFeatureError.new("Improperly defined plan feature: '#{feature}'")
        end

        feature_list << Aria::MasterPlanFeature.new({ :name => name, :value => data, :type => type, :count => count, :rank => rank })
      end
      feature_list
    end
  end
end
