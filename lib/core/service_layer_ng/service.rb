# frozen_string_literal: true

module Core
  module ServiceLayerNg
    # Service class
    # each service in app/services/service_layer should inherit from this class.
    # It provides the context of current user
    class Service
      attr_accessor :services
      attr_reader :api_client
      delegate :catalog, to: :@api_client

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
    end
  end
end
