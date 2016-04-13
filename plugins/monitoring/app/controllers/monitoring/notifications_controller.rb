module Monitoring
  class NotificationsController < DashboardController
    authorization_context 'monitoring'

    def index
      notifications = services.monitoring.notifications
      sorted_notifications = []
      # sort by name
      notifications.sort_by(&:name).each do |notification|
        sorted_notifications << notification
      end

      @notifications = Kaminari.paginate_array(sorted_notifications).page(params[:page]).per(10)
    end

  end
end
