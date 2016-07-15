module Automation

  class ApplicationController < DashboardController
    render_error_page_for [
      {
        "RubyArcClient::ApiError" => {
          header_title: "Monsoon Automation", 
          details: -> e { e.json_hash.empty? ? e.inspect : e.json_hash}, 
          title: :status, 
          error_id: :id
        }
      }
    ]
  end

end