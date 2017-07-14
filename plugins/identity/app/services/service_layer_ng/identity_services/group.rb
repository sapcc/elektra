# frozen_string_literal: true

module ServiceLayerNg
  module IdentityServices
    # This module implements Openstack Group API
    module Group
      def user_groups
        api.identity.list_groups_to_which_a_user_belongs.map_to(Identity::Group)
      end

      def groups(filter = {})
        api.identity.list_groups(filter).map_to(Identity::Group)
      end

      # This method is used by model.
      # It has to return the data hash.
      def create_group(attributes = {})
        api.identity.create_group(group: attributes).data
      end

      # This method is used by model.
      def delete_group(group_id)
        api.identity.delete_group(group_id)
      end

      def new_group(attributes = {})
        map_to(Identity::Group, attributes)
      end

      def find_group!(id)
        api.identity.show_group_details(id).map_to(Identity::Group)
      end

      def find_group(id)
        find_group!(id)
      rescue
        nil
      end

      def group_members(group_id, filter = {})
        api.identity
           .list_users_in_group(group_id, filter)
           .map_to(Identity::User)
      end

      def add_group_member(group_id, user_id)
        api.identity.add_user_to_group(group_id, user_id)
      end

      def remove_group_member(group_id, user_id)
        api.identity.remove_user_from_group(group_id, user_id)
      end
    end
  end
end
