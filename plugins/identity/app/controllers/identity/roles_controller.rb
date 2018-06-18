# frozen_string_literal: true

module Identity
  # This class implements roles actions
  class RolesController < ::DashboardController
    include Identity::RestrictedRoles

    def index
      render json: { roles: available_roles }
    end
  end
end
