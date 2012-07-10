#
# Backport from the 1.8.0 release of webmock a way to do partial
# query mapping.  Based on https://github.com/bblimke/webmock/blob/8989b85cc48087310c27631ce0602608cab6d428/lib/webmock/request_pattern.rb
#
require 'webmock'

raise 'Remove me' if WebMock::VERSION >= '1.8'

def hash_including(hash)
  WebMock::Matchers::HashIncludingMatcher.new(hash)
end

module WebMock
  class URIPattern
    #include RSpecMatcherDetector

    def initialize(pattern)
      @pattern = pattern.is_a?(Addressable::URI) ? pattern : WebMock::Util::URI.normalize_uri(pattern)
      @query_params = nil
    end

    def add_query_params(query_params)
      @query_params = if query_params.is_a?(Hash)
        query_params
      elsif query_params.is_a?(WebMock::Matchers::HashIncludingMatcher)
        query_params
      elsif rSpecHashIncludingMatcher?(query_params)
        WebMock::Matchers::HashIncludingMatcher.from_rspec_matcher(query_params)
      else
        Addressable::URI.parse('?' + query_params).query_values
      end
    end

    def to_s
      str = @pattern.inspect
      str += " with query params #{@query_params.inspect}" if @query_params
      str
    end
  end

  class URIRegexpPattern < URIPattern
    def matches?(uri)
      WebMock::Util::URI.variations_of_uri_as_strings(uri).any? { |u| u.match(@pattern) } &&
        (@query_params.nil? || @query_params == uri.query_values)
    end

    def to_s
      str = @pattern.inspect
      str += " with query params #{@query_params.inspect}" if @query_params
      str
    end
  end

  class URIStringPattern < URIPattern
    def matches?(uri)
      if @pattern.is_a?(Addressable::URI)
        if @query_params
          uri.omit(:query) === @pattern && (@query_params.nil? || @query_params == uri.query_values)
        else
          uri === @pattern
        end
      else
        false
      end
    end

    def add_query_params(query_params)
      super
      if @query_params.is_a?(Hash) || @query_params.is_a?(String)
        @pattern.query_values = (@pattern.query_values || {}).merge(@query_params)
        @query_params = nil
      end
    end

    def to_s
      str = WebMock::Util::URI.strip_default_port_from_uri_string(@pattern.to_s)
      str += " with query params #{@query_params.inspect}" if @query_params
      str
    end
  end
end

# From https://github.com/bblimke/webmock/blob/887bf32ec8a57fc8a457a25afdc398ce3988b8b3/lib/webmock/matchers/hash_including_matcher.rb
module WebMock
  module Matchers
    #this is a based on RSpec::Mocks::ArgumentMatchers::HashIncludingMatcher
    #https://github.com/rspec/rspec-mocks/blob/master/lib/rspec/mocks/argument_matchers.rb
    class HashIncludingMatcher
      def initialize(expected)
        @expected = Hash[WebMock::Util::HashKeysStringifier.stringify_keys!(expected).sort]
      end

      def ==(actual)
        # Use === instead of == to handle regex
        @expected.all? {|k,v| actual.has_key?(k) && v === actual[k]}
      rescue NoMethodError
        false
      end

      def inspect
        "hash_including(#{@expected.inspect})"
      end

      def self.from_rspec_matcher(matcher)
        new(matcher.instance_variable_get(:@expected))
      end
    end
  end
end
