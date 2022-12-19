# frozen_string_literal: true

module ServiceLayer
  module IdentityServices
    # This module implements Openstack Group API
    module Group
      def group_map
        @group_map ||= class_map_proc(Identity::Group)
      end

      def user_map
        @user_map ||= class_map_proc(Identity::User)
      end

      def user_groups(user_id)
        elektron_identity.get("users/#{user_id}/groups").map_to(
          "body.groups",
          &group_map
        )
      end

      def groups(filter = {})
        elektron_identity.get("groups", filter).map_to(
          "body.groups",
          &group_map
        )
      end

      def new_group(attributes = {})
        group_map.call(attributes)
      end

      def find_group!(id)
        elektron_identity.get("groups/#{id}").map_to("body.group", &group_map)
      end

      def find_group(id)
        find_group!(id)
      rescue Elektron::Errors::ApiResponse
        nil
      end

      def group_members(group_id, filter = {})
        elektron_identity.get("groups/#{group_id}/users", filter).map_to(
          "body.users",
          &user_map
        )
      end

      def add_group_member(group_id, user_id)
        elektron_identity.put("groups/#{group_id}/users/#{user_id}")
      end

      def remove_group_member(group_id, user_id)
        elektron_identity.delete("groups/#{group_id}/users/#{user_id}")
      end

      ################### MODEL INTERFACE ###################
      # This method is used by model.
      # It has to return the data hash.
      def create_group(attributes = {})
        elektron_identity.post("groups") { { group: attributes } }.body["group"]
      end

      # This method is used by model.
      def delete_group(group_id)
        elektron_identity.delete("groups/#{group_id}")
      end
    end
  end
end
