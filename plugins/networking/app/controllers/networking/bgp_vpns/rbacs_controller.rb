# frozen_string_literal: true

require 'ipaddr'

module Networking
  module SecurityGroups
    # Implements Security Group Rule actions
    class RbacsController < ::AjaxController

      def index
        rbacs = services.networking.rbacs(
          object_id: params[:security_group_id], object_type: 'security_group'
        )

        render json: rbacs
      rescue Elektron::Errors::ApiResponse => e
        render json: { errors: e.message }, status: e.code
      end
  
      def create
        rbac = services.networking.new_rbac(params[:rbac])
        rbac.object_id     = params[:security_group_id]
        rbac.target_tenant = params[:target_tenant]
        rbac.object_type   = 'security_group'
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
