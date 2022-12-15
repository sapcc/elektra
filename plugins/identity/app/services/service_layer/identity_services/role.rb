# frozen_string_literal: true

module ServiceLayer
  module IdentityServices
    # This module implements Openstack Role API
    module Role
      def role_map
        @role_map ||= class_map_proc(Identity::Role)
      end

      def roles(filter = {})
        elektron_identity.get("roles", filter).map_to("body.roles", &role_map)
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
