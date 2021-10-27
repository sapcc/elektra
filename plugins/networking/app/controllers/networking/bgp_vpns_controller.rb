# frozen_string_literal: true

module Networking
  # Implements Network actions
  class BgpVpnsController < AjaxController

    # set policy context
    authorization_context 'networking'
    # enforce permission checks. This will automatically
    # investigate the rule name.
    authorization_required only: %i[index]

    def index
      code, bgp_vpns = services.networking.bgp_vpns()

      # this is relevant in case an ajax paginate call is made.
      # in this case we don't render the layout, only the list!
      if code.to_i >= 400
        render json: {errors: bgp_vpns}, status: code
      else
        render json: bgp_vpns
      end 
    end

    def routers
      # load all avilable routers
      routers = services.networking.routers(limit: 500,fields:[:external_gateway_info, :id,:name,:project_id])
      # load all port owned by router_interface
      ports = services.networking.ports(limit: 500, device_owner: 'network:router_interface', fields: [:device_id,:network_id])
      # load all project subnets
      subnets = services.networking.subnets(limit: 500, fields: [:name,:cidr,:network_id,:project_id,:id])

      routers.each do |router|
        ports.select{ |port| port.device_id === router.id }.each do |port|
          router.subnets = subnets.select{|subnet| subnet.network_id === port.network_id}
        end
      end      

      render json: {routers: routers}
    rescue Elektron::Errors::ApiResponse => e
      ender json: {errors: e.messages.join(', ') }
    end

    def router_associations
      code, router_associations = services.networking.router_associations(params[:id])

      # this is relevant in case an ajax paginate call is made.
      # in this case we don't render the layout, only the list!
      if code.to_i >= 400
        render json: {errors: router_associations}, status: code
      else
        render json: router_associations
      end 
    end

    def create_router_association
      code, router_association = services.networking.create_router_association(params[:id],params[:router_id])

      # this is relevant in case an ajax paginate call is made.
      # in this case we don't render the layout, only the list!
      if code.to_i >= 400
        render json: {errors: router_association}, status: code
      else
        render json: router_association
      end 
    end

    def destroy_router_association
      code, errors = services.networking.delete_router_association(params[:id],params[:router_association_id])

      # this is relevant in case an ajax paginate call is made.
      # in this case we don't render the layout, only the list!
      if code.to_i >= 400
        render json: {errors: errors}, status: code
      else
        head code
      end 
    end
  end
end
