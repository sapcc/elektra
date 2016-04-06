module BlockStorage
  class ApplicationController < DashboardController

    def target_state_for_action(action)
      case action
        when 'attach' then 'in-use'
        when 'detach' then 'available'
      end
    end

  end
end