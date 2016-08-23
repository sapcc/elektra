module KeyManager
  module Driver
    class Fog < Core::ServiceLayer::Driver::Base
      include Core::ServiceLayer::FogDriver::ClientHelper
      attr_reader :available

      def initialize(params)
        super(params)
        @params = params
        @fog = ::Fog::KeyManager::OpenStack.new(auth_params)
        @available = true
      rescue ::Fog::OpenStack::Errors::ServiceUnavailable
        @fog = nil
        @available = false
      end
      
      def secrets(filter={})
        handle_response{
          # @fog.list_secrets(filter).body['secrets']
          @fog.secrets.all
        }
      end

      def secret(uuid)
        handle_response{
          @fog.secrets.get(uuid)
        }
      end
    end
  end
end