module SharedFilesystemStorage
  module ShareNetworks
    class SecurityServicesController < ApplicationController

      def index
        services.shared_filesystem_storage.security_services_detail(share_network_id: params[:share_network_id])
      end

      def create
      end

      def destroy

      end
    end
  end
end
