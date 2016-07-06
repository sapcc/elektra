module BlockStorage
  class ApplicationController < DashboardController

    # token is expired or was revoked -> redirect to login page
    rescue_from Core::ServiceLayer::Errors::ApiError do |exception|
      @exception = ""
      exception.message.each_line.with_index do |l, i|
        @exception += l if i < 25
      end
      @exception += " ..."
      render 'block_storage/application/service_error'
    end

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