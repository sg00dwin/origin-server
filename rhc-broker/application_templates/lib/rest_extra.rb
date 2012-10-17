module RHC
  module Rest
    class Application
      #Get descriptor for this application
      def descriptor
        logger.debug "Getting descriptor for application #{self.name}" if @mydebug
        rest_method "GET_DESCRIPTOR"
      end
    end

    class Client
      #Get all templates
      def templates
        logger.debug "Getting all templates" if @mydebug
        rest_method "LIST_TEMPLATES"
      end
    end
  end
end
