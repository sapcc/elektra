# frozen_string_literal: true

module ServiceLayerNg
  # This class implements the identity api
  class IdentityService < Core::ServiceLayerNg::Service
    include User
    include Project
    include Domain
    include Group
    include Role
    include RoleAssignment
    include OsCredential

    def available?(_action_name_sym = nil)
      !current_user.service_url('identity', region: region).nil?
    end
  end
end
