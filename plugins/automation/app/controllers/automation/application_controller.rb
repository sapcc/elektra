module Automation

  class ApplicationController < DashboardController
    rescue_and_render_error_page [
      {
        "RubyArcClient::ApiError" => {
          header_title: "Monsoon Automation", 
          details: -> e, c { e.json_hash.empty? ? e.inspect : e.json_hash},
          description: :title,
          title: :status
        }
      }
    ]
  end

end
