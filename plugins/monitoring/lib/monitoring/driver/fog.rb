module Monitoring
  module Driver
    class Fog < Interface
      include Core::ServiceLayer::FogDriver::ClientHelper

      def initialize(params_or_driver)
        # support initialization by given driver
        if params_or_driver.is_a?(::Fog::Monitoring::OpenStack)
          @fog = params_or_driver
        else
          super(params_or_driver)
          # don't include useless request/response dumps in exception messages
          no_debug = { debug: false, debug_request: false, debug_response: false}
          @fog = ::Fog::Monitoring::OpenStack.new(auth_params.merge(connection_options: no_debug))
        end
      end

      def alarm_definitions
        handle_response do
          @fog.alarm_definitions.all
        end
      end
    end
  end
end


