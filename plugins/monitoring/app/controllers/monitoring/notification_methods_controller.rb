module Monitoring
  class NotificationMethodsController < Monitoring::ApplicationController
    authorization_required

    before_filter :load_notification_method, except: [ :index, :new, :create, :search ]

    def index
      @context = 'notification_methods'
      notification_methods_search = cookies[:notification_methods_search] || ''
      unless notification_methods_search.empty?
        search
      else
        all_notification_methods = services.monitoring.notification_methods.sort_by(&:name)
        @notification_methods_count = all_notification_methods.length
      @notification_methods = Kaminari.paginate_array(all_notification_methods).page(params[:page]).per(10)
      end
    end

    def new
      @notification_method = services.monitoring.new_notification_method(name: "")
    end

    def edit
    end

    def show
    end

    def search
      @search = params[:search] || cookies[:notification_methods_search] || ''
      searched_notification_methods = services.monitoring.notification_methods(@search)
      @notification_methods_count = searched_notification_methods.length
      @notification_methods = Kaminari.paginate_array(searched_notification_methods).page(params[:page]).per(10)
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
      attrs = params.require(:notification_method).permit(:name, :type, :address)
      unless @notification_method.update_attributes(attrs)
        render action: 'edit'
        return
      end
      back_to_notification_method_list
    end

    def destroy 
       @notification_method.destroy
       back_to_notification_method_list
    end

    private

    def back_to_notification_method_list
      # only load the notification methods list
      respond_to do |format|
        format.js do
          index
          render action: 'list'
        end
        # render index site
        format.html { redirect_to plugin('monitoring').notification_methods_path }
      end
    end

    def load_notification_method
      @notification_method = services.monitoring.get_notification_method(params.require(:id))
      # @notification_method is loaded before destoy and update so we only need to take care in one place
      raise ActiveRecord::RecordNotFound, "The notification method with id #{params[:id]} was not found. Maybe it was deleted from someone else?" unless @notification_method.try(:id)
    end
    
  end
end
