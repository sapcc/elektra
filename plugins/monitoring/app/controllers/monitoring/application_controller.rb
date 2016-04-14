module Monitoring
  class ApplicationController < DashboardController
    authorization_context 'monitoring'

    rescue_from Excon::Errors::Error do |exception|
      # get exception message
      response = JSON.parse(exception.response.body)
      reason = response.keys[0] || ""
      @exception_msg = "#{reason.capitalize} - #{response[reason]['message']}"
      
      render template: '/monitoring/application/backend_error'
    end



  end
end
