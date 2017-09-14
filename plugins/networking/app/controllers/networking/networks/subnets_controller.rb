module Networking
  module Networks
    class SubnetsController < DashboardController
      def index
        render json: services_ng.networking.subnets(
          network_id: params[:network_id]
        )
      end

      def create
        subnet = services_ng.networking.new_subnet(
          params[:subnet].merge(network_id: params[:network_id])
        )
        if subnet.save
          render json: subnet, status: 201
        else
          render json: { errors: subnet.errors }, status: 400
        end
      end

      def destroy
        head 204
      end
    end
  end
end
