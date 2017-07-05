# frozen_string_literal: true

module ServiceLayerNg
  # This module implements Openstack User API
  module Users
    def users(filter = {})
      api.identity.list_users(filter).map_to(Identity::UserNg)
    end

    def find_user(id)
      api.identity.show_user_details(id).map_to(Identity::UserNg)
    end

    def new_user(attributes = {})
      map_to(Identity::UserNg, attributes)
    end

    def delete_user(id)
      api.identity.delete_user(id)
    end
  end
end
