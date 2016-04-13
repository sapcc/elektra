module Monitoring
  module Driver
    class Interface < Core::ServiceLayer::Driver::Base
      
      def alarm_definitions
        raise Core::ServiceLayer::Errors::NotImplemented
      end

      def get_alarm_definition(id)
        raise Core::ServiceLayer::Errors::NotImplemented
      end

      def delete_alarm_definition(id)
        raise Core::ServiceLayer::Errors::NotImplemented
      end

      def notifications
        raise Core::ServiceLayer::Errors::NotImplemented
      end

      def alarms
        raise Core::ServiceLayer::Errors::NotImplemented
      end

      def create_notification
        raise Core::ServiceLayer::Errors::NotImplemented
      end

      def get_notification(id)
        raise Core::ServiceLayer::Errors::NotImplemented
      end
    end
  end
end
