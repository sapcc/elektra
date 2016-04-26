module Monitoring
  class NotificationMethodsController < Monitoring::ApplicationController
    authorization_context 'monitoring'

    def index
      notification_methods = services.monitoring.notification_methods
      sorted_notification_methods = []
      # sort by name
      notification_methods.sort_by(&:name).each do |notification_method|
        sorted_notification_methods << notification_method
      end

      @notification_methods = Kaminari.paginate_array(sorted_notification_methods).page(params[:page]).per(10)
    end

    def new
      @notification_method = services.monitoring.new_notification_method(name: "")
    end

    def edit
      @notification_method = services.monitoring.get_notification_method(params.require(:id))
    end

    def create
      @notification_method = services.monitoring.new_notification_method(params.require(:notification_method))
      unless @notification_method.save
        render action: 'new'
        return
      end
      back_to_notification_method_list
    end

    def update
      @notification_method = services.monitoring.get_notification_method(params.require(:id))
      attrs = params.require(:notification_method).permit(:name, :type, :address)
      unless @notification_method.update_attributes(attrs)
        render action: 'edit'
        return
      end
      back_to_notification_method_list
    end

    def destroy 
       notification_method = services.monitoring.get_notification_method(params.require(:id))
       raise ActiveRecord::RecordNotFound, "Notification with id #{params[:id]} not found" unless notification_method
       notification_method.destroy
       back_to_notification_method_list
    end

    private

    def back_to_notification_method_list
      respond_to do |format|
        format.js do
          notification_methods = services.monitoring.notification_methods
          @notification_methods = Kaminari.paginate_array(notification_methods).page(params[:page]).per(10)
          render action: 'reload_list'
        end
        format.html { redirect_to plugin('monitoring').notification_methods_path }
      end
    end
    
  end
end
