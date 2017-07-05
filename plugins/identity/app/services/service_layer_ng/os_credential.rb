# frozen_string_literal: true

module ServiceLayerNg
  # This module implements Openstack Credential API
  module OsCredential
    def new_credential(attributes = {})
      map_to(Identity::OsCredential, attributes)
    end

    def find_credential(id = nil)
      return nil if id.blank?
      api.identity.show_credential_details(id).map_to(Identity::OsCredentialNg)
    end

    def credentials(filter = {})
      @user_credentials ||= api.identity.list_credentials(filter)
                               .map_to(Identity::OsCredentialNg)
    end
  end
end
