# frozen_string_literal: true

module ServiceLayer
  module SharedFilesystemStorageServices
    # This module implements Openstack Designate Pool API
    module SecurityService
      def security_service_map
        @share_rule_map ||=
          class_map_proc(SharedFilesystemStorage::SecurityService)
      end

      def security_services(filter = {})
        elektron_shares.get("security-services", filter).map_to(
          "body.security_services",
          &security_service_map
        )
      end

      def new_security_service(params = {})
        security_service_map.call(params)
      end

      def security_services_detail(filter = {})
        elektron_shares.get("security-services/detail", filter).map_to(
          "body.security_services",
          &security_service_map
        )
      end

      def find_security_service!(id)
        elektron_shares.get("security-services/#{id}").map_to(
          "body.security_service",
          &security_service_map
        )
      end

      def find_security_service(id)
        find_security_service!(id)
      rescue Elektron::Errors::ApiResponse => _e
        nil
      end

      ################# INTERFACE METHODS ######################
      def create_security_service(params)
        elektron_shares
          .post("security-services") { { security_service: params } }
          .body[
          "security_service"
        ]
      end

      def update_security_service(id, params)
        elektron_shares
          .put("security-services/#{id}") { { security_service: params } }
          .body[
          "security_service"
        ]
      end

      def delete_security_service(id)
        elektron_shares.delete("security-services/#{id}")
      end
    end
  end
end
