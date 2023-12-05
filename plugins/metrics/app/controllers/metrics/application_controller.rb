# frozen_string_literal: true
module Metrics
  class ApplicationController < DashboardController
    authorization_context "metrics"
    authorization_required

    def index
      enforce_permissions("metrics:application_list")
    end
  end
end
