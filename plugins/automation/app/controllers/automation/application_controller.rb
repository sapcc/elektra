module Automation

  class ApplicationController < DashboardController
    rescue_and_render_error_page [
      {
        "RubyArcClient::ApiError" => {
          header_title: "Monsoon Automation", 
          details: -> e, c { e.json_hash.empty? ? e.inspect : e.json_hash},
          description: :title,
          title: :status, 
          error_id: :id
        }
      },
      {
        "ServiceLayer::AutomationApiError" => {
          header_title: "Monsoon Automation",
          details: -> e, c {e.data.to_yaml},
          description: -> e, c {
            body = JSON.parse(e.data.body) rescue nil
            unless body.nil?
              unless body['error'].nil?
                return body['error']
              end
            end
            return e.data.body
          },
          title: -> e, c {e.data.message},
        }
      }
    ]
  end

end