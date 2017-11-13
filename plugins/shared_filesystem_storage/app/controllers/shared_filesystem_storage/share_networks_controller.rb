module SharedFilesystemStorage
  class ShareNetworksController < ApplicationController

    def index
      share_networks = services.shared_filesystem_storage.share_networks_detail
      # extend attributes with permissions
      share_networks.each do |sn|
        sn.permissions = {
          get: current_user.is_allowed?("shared_filesystem_storage:share_network_get"),
          delete: current_user.is_allowed?("shared_filesystem_storage:share_network_delete"),
          update: current_user.is_allowed?("shared_filesystem_storage:share_network_update")
        }
      end

      render json: share_networks
    end

    def update
      share_network = services.shared_filesystem_storage.new_share_network(share_network_params)
      share_network.id = params[:id]

      if share_network.save
        share_network.permissions = {
          get: current_user.is_allowed?("shared_filesystem_storage:share_network_get"),
          delete: current_user.is_allowed?("shared_filesystem_storage:share_network_delete"),
          update: current_user.is_allowed?("shared_filesystem_storage:share_network_update")
        }
        render json: share_network
      else
        render json: { errors: share_network.errors }
      end
    end

    def networks
      render json: services_ng.networking.networks('router:external' => false)
    end

    def subnets
      render json: services_ng.networking.subnets(network_id: params[:network_id])
    end

    def create
      share_network = services.shared_filesystem_storage.new_share_network(share_network_params)

      if share_network.save
        share_network.cidr=params[:share_network][:cidr] if params[:share_network][:cidr]
        share_network.permissions = {
          get: current_user.is_allowed?("shared_filesystem_storage:share_network_get"),
          delete: current_user.is_allowed?("shared_filesystem_storage:share_network_delete"),
          update: current_user.is_allowed?("shared_filesystem_storage:share_network_update")
        }
        render json: share_network
      else
        render json: { errors: share_network.errors }
      end
    end

    def destroy
      share_network = services.shared_filesystem_storage.new_share_network
      share_network.id=params[:id]

      if share_network.destroy
        head :no_content
      else
        render json: { errors: share_network.errors }
      end
    end

    protected

    def share_network_params
      params.require(:share_network).permit(:name, :description, :neutron_net_id, :neutron_subnet_id)
    end

  end
end
