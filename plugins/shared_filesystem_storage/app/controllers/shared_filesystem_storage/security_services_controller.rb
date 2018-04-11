# frozen_String_literal: true

module SharedFilesystemStorage
  # security services
  class SecurityServicesController < ApplicationController
    def index
      security_services =
        if current_user.is_allowed?(
          'shared_filesystem_storage:security_service_get'
        )
          services.shared_filesystem_storage.security_services_detail
        else
          services.shared_filesystem_storage.security_services
        end

      render json: security_services
    end

    def show
      security_service = services.shared_filesystem_storage
                                    .find_security_service(params[:id])
      render json: security_service
    end

    def update
      security_service = services.shared_filesystem_storage
                                    .new_security_service(
                                      security_service_params
                                    )
      security_service.id = params[:id]

      if security_service.save
        render json: security_service
      else
        render json: { errors: security_service.errors }
      end
    end

    def create
      security_service = services.shared_filesystem_storage
                                    .new_security_service(
                                      security_service_params
                                    )

      if security_service.save
        render json: security_service
      else
        render json: { errors: security_service.errors }
      end
    end

    def destroy
      security_service = services.shared_filesystem_storage
                                    .new_security_service
      security_service.id = params[:id]

      if security_service.destroy
        head :no_content
      else
        render json: { errors: security_service.errors }
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
        :ou
      )
    end
  end
end
