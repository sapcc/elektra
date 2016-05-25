module Monitoring
  class NotificationMethodsController < Monitoring::ApplicationController
    authorization_required

    before_filter :load_notification_method, except: [ :index, :new, :create, :search ]

    def index
      all_notification_methods = services.monitoring.notification_methods.sort_by(&:name)
      @notification_methods_count = all_notification_methods.length
      @notification_methods = Kaminari.paginate_array(all_notification_methods).page(params[:page]).per(10)
    end

    def new
      @notification_method = services.monitoring.new_notification_method(name: "")
    end

    def edit
    end

    def show
    end

    def search
      @search = params[:search]
      searched_notification_methods = services.monitoring.notification_methods(@search)
      @notification_methods_count = searched_notification_methods.length
      @notification_methods = Kaminari.paginate_array(searched_notification_methods).page(params[:page]).per(10)
      render action: 'index'
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
      respond_to do |format|
        format.js do
          index
          render action: 'reload_list'
        end
        format.html { redirect_to plugin('monitoring').notification_methods_path }
      end
    end

    def load_notification_method
      @notification_method = services.monitoring.get_notification_method(params.require(:id))
      raise ActiveRecord::RecordNotFound, "notification method with id #{params[:id]} not found" unless @notification_method
    end
    
  end
end
