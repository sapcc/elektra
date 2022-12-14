module SharedFilesystemStorage
  module ShareNetworks
    class SecurityServicesController < ApplicationController
      def index
        render json:
                 services.shared_filesystem_storage.security_services_detail(
                   share_network_id: params[:share_network_id],
                 )
      end

      def create
        # we don't request share network from API (it is more performant)
        share_network = services.shared_filesystem_storage.new_share_network
        share_network.id = params[:share_network_id]
        security_service =
          services.shared_filesystem_storage.find_security_service(
            params[:security_service][:id],
          )

        if share_network.add_security_service(security_service.id)
          render json: security_service
        else
          render json: { errors: share_network.errors }
        end
      end

      def destroy
        # we don't request share network from API (it is more performant)
        share_network = services.shared_filesystem_storage.new_share_network
        share_network.id = params[:share_network_id]

        if share_network.remove_security_service(params[:id])
          head :no_content
        else
          render json: { errors: share_network.errors }
        end
      end
    end
  end
end
