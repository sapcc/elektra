# frozen_string_literal: true

module Tools
  class CastellumController < ::DashboardController
    def show
      enforce_permissions("::tools:show_castellum_errors")
      @js_data = {
        # data required to access the Castellum API
        token: current_user.token,
        castellum_api: current_user.service_url("castellum"),
      }
    end
  end
end
