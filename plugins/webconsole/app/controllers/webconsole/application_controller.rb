module Webconsole
  class ApplicationController < DashboardController
    def show
      @token = current_user.token
      @webcli_endpoint = current_user.service_url("webcli")
      @identity_url = current_user.service_url("identity")
    end
    
    def credentials
      render json: {
        token: current_user.token,
        webcli_endpoint: current_user.service_url("webcli"),
        identity_url: current_user.service_url("identity")
      }.to_json
    end
  end
end