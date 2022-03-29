# frozen_string_literal: true

module Tools
  class LimesController < ::DashboardController
    def show
      enforce_permissions('::tools:show_limes_errors')
      @js_data = {
        # data required to access the Limes API
        token:     current_user.token,
        limes_api: current_user.service_url('resources'),
      }
    end
  end
end
