# frozen_string_literal: true

module Resources
  class ApplicationController < DashboardController
    def release_state
      'beta'
    end

    def show
      @limes_endpoint = current_user.service_url('resources')
    end
  end
end
