module BareMetalHana
  class ApplicationController < DashboardController
    def index
      @token = current_user.token
      @webcli_endpoint = current_user.service_url("webcli")
      @identity_url = current_user.service_url("identity")
    end
  end
end