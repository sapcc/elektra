# frozen_string_literal: true

module ServiceLayer
  module IdentityServices
    # This module implements Openstack Domain API
    module Domain
      def domain_map
        @domain_map ||= class_map_proc(Identity::Domain)
      end

      def has_domain_access(domain_id)
        user_domains = elektron_identity.get('/auth/domains').map_to(
          'body.domains', &domain_map
        )
        !user_domains.find { |user_domian| user_domian.id == domain_id }.nil?
      end

      def find_domain!(id)
        return nil if id.blank?
        elektron_identity.get("domains/#{id}").map_to(
          'body.domain', &domain_map
        )
      end

      def find_domain(id)
        find_domain!(id)
      rescue Elektron::Errors::ApiResponse
        nil
      end

      def new_domain(attributes = {})
        domain_map.call(attributes)
      end

      def auth_domains
        @domains ||= elektron_identity.get('auth/domains').map_to(
          'body.domains', &domain_map
        )
      end

      def domains(filter = {})
        elektron_identity.get('domains', filter).map_to(
          'body.domains', &domain_map
        )
      end
    end
  end
end
