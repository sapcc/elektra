module Monitoring
  class ApplicationController < DashboardController
    # This is the base class of all controllers in this plugin. 
    # Only put code in here that is shared across controllers.
    authorization_context 'monitoring'

    rescue_from Excon::Errors::HTTPStatusError do |exception|
      # get exception message
      response = JSON.parse(exception.response.body)

      # monasca api error handling
      if response['title'] && response['description']
        title = response['title'] || ""
        description = response['description'] || ""
        @exception_msg = "#{title} - Reason: #{description}"
      else
        # other
        reason = response.keys[0] || ""
        @exception_msg = "#{reason.capitalize} - #{response[reason]['message']}"
      end
      
      render template: '/monitoring/application/backend_error'
    end

  end
end
