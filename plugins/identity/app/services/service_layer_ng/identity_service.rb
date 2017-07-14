# frozen_string_literal: true

module ServiceLayerNg
  # This class implements the identity api
  class IdentityService < Core::ServiceLayerNg::Service
    include IdentityServices::User
    include IdentityServices::Project
    include IdentityServices::Domain
    include IdentityServices::Group
    include IdentityServices::Role
    include IdentityServices::RoleAssignment
    include IdentityServices::OsCredential

    def available?(_action_name_sym = nil)
      api.catalog_include_service?('identity', region)
    end
  end
end
