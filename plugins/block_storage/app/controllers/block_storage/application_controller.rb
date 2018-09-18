module BlockStorage
  class ApplicationController < DashboardController
    def widget; end

    # def target_state_for_action(action)
    #   case action
    #     when 'attach' then ['in-use', 'available']
    #     when 'detach' then ['available', 'in-use']
    #     when 'create' then ['available', 'error']
    #     when 'destroy' then ['error_deleting', 'in-use']
    #   end
    # end

  end
end
