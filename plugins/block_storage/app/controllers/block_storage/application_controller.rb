module BlockStorage
  class ApplicationController < DashboardController
    render_error_page_for [
      {
        "Core::ServiceLayer::Errors::ApiError" => {
          header_title: 'Backend Service', 
          title: 'Error happend during backend  call', 
          details: -> e { e.json_hash.empty? ? e.inspect : e.json_hash}
        }
      }
    ]

    def target_state_for_action(action)
      case action
        when 'attach' then ['in-use', 'available']
        when 'detach' then ['available', 'in-use']
        when 'create' then ['available', 'error']
        when 'destroy' then ['error_deleting', 'in-use']
      end
    end

  end
end