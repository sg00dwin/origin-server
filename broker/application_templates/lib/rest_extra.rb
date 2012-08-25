module Rhc
  module Rest
    class Application
      #Get descriptor for this application
      def descriptor
        logger.debug "Getting descriptor for application #{self.name}" if @mydebug
        url = @links['GET_DESCRIPTOR']['href']
        method =  @links['GET_DESCRIPTOR']['method']
        request = RestClient::Request.new(:url => url, :method => method, :headers => @@headers)
        return request(request)
      end
    end

    class Client
      #Get all templates
      def templates
        logger.debug "Getting all templates" if @mydebug
        url = @links['LIST_TEMPLATES']['href']
        method =  @links['LIST_TEMPLATES']['method']
        request = RestClient::Request.new(:url => url, :method => method, :headers => @@headers)
        return request(request)
      end
    end
  end
end
