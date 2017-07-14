# frozen_string_literal: true

module ServiceLayerNg
  module IdentityServices
    # This module implements Openstack Domain API
    module Domain
      def find_domain!(id)
        return nil if id.blank?
        api.identity.show_domain_details(id).map_to(Identity::Domain)
      end

      def find_domain(id)
        find_domain!(id)
      rescue
        nil
      end

      def new_domain(attributes = {})
        map_to(Identity::Domain, attributes)
      end

      def auth_domains
        @domains ||= api.identity
                        .get_available_domain_scopes.map_to(Identity::Domain)
      end

      def domains(filter = {})
        api.identity.list_domains(filter).map_to(Identity::Domain)
      end
    end
  end
end
