module Monitoring
  module Driver
    class Interface < Core::ServiceLayer::Driver::Base
      
      def alarm_definitions
        raise Core::ServiceLayer::Errors::NotImplemented
      end

      def get_alarm_definition(id)
        raise Core::ServiceLayer::Errors::NotImplemented
      end
    
    end
  end
end
