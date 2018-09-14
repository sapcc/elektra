module Automation
  class ApplicationController < DashboardController
    rescue_from 'ArcClient::ApiError' do |exception|
      options = {
        title: :title,
        description: :detail,
        warning: true, sentry: true
      }

      if params[:polling_service]
        head status: 500
      else
        render_exception_page(exception, options)
      end
    end

    # rescue_and_render_exception_page [
    #   {
    #     "ArcClient::ApiError" => {
    #       header_title: "Monsoon Automation",
    #       details: -> e, c { e.json_hash.empty? ? e.inspect : e.json_hash},
    #       description: :title,
    #       title: :status
    #     }
    #   }
    # ]
  end
end
