# frozen_string_literal: true

module ServiceLayerNg
  module IdentityServices
    # This module implements Openstack Role API
    module Role
      def roles
        @roles ||= api.identity.list_roles.map_to(Identity::Role)
      end

      def find_role(id)
        return nil if id.blank?
        roles.select { |r| r.id == id }.first
      end

      def find_role_by_name(name)
        roles.select { |r| r.name == name }.first
      end
    end
  end
end
