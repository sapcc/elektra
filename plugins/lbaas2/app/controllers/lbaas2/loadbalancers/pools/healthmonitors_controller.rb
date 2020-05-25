module Lbaas2
  module Loadbalancers
    module Pools
      class HealthmonitorsController < ApplicationController

        def show
          healthmonitor = services.lbaas2.find_healthmonitor(params[:id])
          render json: {
            healthmonitor: healthmonitor
          }
        rescue Elektron::Errors::ApiResponse => e
          render json: { errors: e.message }, status: e.code
        rescue Exception => e
          render json: { errors: e.message }, status: "500"
        end  

        def create
          healthMonitorParams = params[:healthmonitor]
          newParams = healthMonitorParams.merge(project_id: @scoped_project_id, pool_id: params[:pool_id])
          healthmonitor = services.lbaas2.new_healthmonitor()
          healthmonitor.attributes = newParams.delete_if{ |_k, v| v.blank? }

          if healthmonitor.save
            audit_logger.info(current_user, 'has created', healthmonitor)
            render json: healthmonitor
          else
            render json: {errors: healthmonitor.errors}, status: 422
          end
        rescue Elektron::Errors::ApiResponse => e
          render json: { errors: e.message }, status: e.code
        rescue Exception => e
          render json: { errors: e.message }, status: "500"
        end

      end
    end
  end
end
