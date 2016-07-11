module Automation

  class ApplicationController < DashboardController
    rescue_from RubyArcClient::ApiError do |exception|
      Rails.logger.error "Automation-plugin: index action: #{exception.to_s}"
      @error = exception
      @details = exception.json_hash.empty? ? exception.inspect : exception.json_hash

      if request.xhr? && params[:polling_service]
        @key = "error"
        @value = exception.to_s
        # respond to Ajax request
        render "automation/shared/error_javascript.js", format: "JS"
      else
        render "automation/shared/error_page"
      end
    end

  end

end