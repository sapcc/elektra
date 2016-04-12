module Monitoring
  class NotificationsController < DashboardController
    authorization_context 'monitoring'

    def index
      @notifications = services.monitoring.notifications
    end

  end
end
