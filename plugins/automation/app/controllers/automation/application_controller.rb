module Automation

  class ApplicationController < DashboardController

    rescue_from RubyArcClient::ApiError do |exception|
      Rails.logger.error "Automation-plugin: index action: #{exception.to_s}"
      @error = exception
      render "automation/shared/error_page"
    end

  end

end