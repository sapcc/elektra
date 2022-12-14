# frozen_string_literal: true

module Identity
  module Users
    class RoleAssignmentsController < Identity::ApplicationController
      def index
        respond_to do |format|
          format.html {}
          format.json do
            role_assignments =
              services.identity.origin_role_assignments(
                "user.id" => params[:user_id],
                :include_names => true,
                :effective => true,
              )
            render json: { roles: role_assignments }
          end
        end
      end
    end
  end
end
