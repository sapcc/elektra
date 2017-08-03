# frozen_string_literal: true

module Kubernetes
  class ApplicationController < DashboardController
    def index
      @kubernikus_endpoint = "#{current_user.service_url('kubernikus')}/api/v1"
    end
  end
end
