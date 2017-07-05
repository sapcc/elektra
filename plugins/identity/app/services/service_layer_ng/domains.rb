# frozen_string_literal: true

module ServiceLayerNg
  # This module implements Openstack Domain API
  module Domains
    def find_domain(id)
      return nil if id.blank?
      api.identity.show_domain_details(id).map_to(Identity::DomainNg)
    end

    def new_domain(attributes = {})
      map_to(Identity::DomainNg, attributes)
    end

    def auth_domains
      @domains ||= api.identity
                      .get_available_domain_scopes.map_to(Identity::DomainNg)
    end

    def domains(filter = {})
      api.identity.list_domains(filter).map_to(Identity::DomainNg)
    end
  end
end
