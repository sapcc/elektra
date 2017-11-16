module SharedFilesystemStorage
  class SecurityServicesController < ApplicationController

    def index
      security_services = if current_user.is_allowed?("shared_filesystem_storage:security_service_get")
        services.shared_filesystem_storage.security_services_detail
      else
        services.shared_filesystem_storage.security_services
      end

      security_services.each{ |security_service| set_permissions(security_service)}
      render json: security_services
    end

    def show
      security_service = services.shared_filesystem_storage.find_security_service(params[:id])
      set_permissions(security_service)
      render json: security_service
    end

    def update
      security_service = services.shared_filesystem_storage.new_security_service(security_service_params)
      security_service.id = params[:id]

      if security_service.save
        set_permissions(security_service)
        render json: security_service
      else
        render json: { errors: security_service.errors }
      end
    end

    def create
      security_service = services.shared_filesystem_storage.new_security_service(security_service_params)

      if security_service.save
        set_permissions(security_service)
        render json: security_service
      else
        render json: { errors: security_service.errors}
      end
    end

    def destroy
      security_service = services.shared_filesystem_storage.new_security_service
      security_service.id=params[:id]

      if security_service.destroy
        head :no_content
      else
        render json: { errors: security_service.errors}
      end
    end

    protected
    def security_service_params
      params.require(:security_service).permit(
        :description,
        :dns_ip,
        :user,
        :password,
        :type,
        :name,
        :domain,
        :server,
        :ou
      )
    end

    def set_permissions(security_service)
      security_service.permissions = {
        delete: current_user.is_allowed?("shared_filesystem_storage:security_service_delete"),
        update: current_user.is_allowed?("shared_filesystem_storage:security_service_update"),
        get: current_user.is_allowed?("shared_filesystem_storage:security_service_get")
      }
    end
  end
end
