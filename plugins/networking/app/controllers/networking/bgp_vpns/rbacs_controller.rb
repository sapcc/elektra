# frozen_string_literal: true

require 'ipaddr'

module Networking
  module BgpVpns
    # Implements BGP VPN RBAC actions
    class RbacsController < ::AjaxController

      def index
        rbacs = services.networking.rbacs(
          object_id: params[:bgp_vpn_id], object_type: 'bgpvpn'
        )

        render json: rbacs
      rescue Elektron::Errors::ApiResponse => e
        render json: { errors: e.message }, status: e.code
      end
      
  
      def create
        rbac = services.networking.new_rbac(params[:rbac])
        rbac.object_id     = params[:bgp_vpn_id]
        rbac.target_tenant = params[:target_tenant]
        rbac.object_type   = 'bgpvpn'
        rbac.action        = 'access_as_shared'

        if rbac.save
          render json: rbac
        else
          render json: { errors: rbac.errors }, status: 400
        end
      end
  
      def destroy
        rbac = services.networking.new_rbac
        rbac.id = params[:id]
  
        if rbac.destroy
          head :ok
        else
          render json: {errors: rbac.errors}, status: 400
        end
      end
    end
  end
end
