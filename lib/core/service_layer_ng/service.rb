# frozen_string_literal: true

module Core
  module ServiceLayerNg
    # Service class
    # each service in app/services/service_layer should inherit from this class.
    # It provides the context of current user
    class Service
      attr_accessor :services
      attr_reader :api_client, :region

      def initialize(api_client)
        @api_client = api_client
        @region = ::Core.region_from_auth_url ||
                  ::Core.locate_region(service_user,
                                       Rails.configuration.default_region)
      end

      def available?(_action_name_sym = nil)
        false
      end

      def api
        @api ||= ::Core::Api::ClientWrapper.new(@api_client, self)
      end

      def inspect
        { service: self.class.name, region: region }.to_s
      end

      # This method is used to map raw data to a Object.
      def self.map_to(klazz, data, options = {}, &block)
        if data.is_a?(Array)
          data.collect do |item|
            create_map_object(klazz, item.merge(options), &block)
          end
        elsif data.is_a?(Hash)
          create_map_object(klazz, data.merge(options), &block)
        else
          data
        end
      end

      def map_to(klass, data, options = {})
        if data.is_a?(Array)
          data.collect do |item|
            klass.send(:new, self, (item || {}).merge(options))
          end
        elsif data.is_a?(Hash)
          klass.send(:new, self, data.merge(options))
        else
          data
        end
      end

      # def catalog
      #   api_client.instance_variable_get('@auth').catalog
      # end
      
      def debug(message)
        puts message if ENV['DEBUG_SERVICE_LAYER']
      end
    end
  end
end
