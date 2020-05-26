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
          healthMonitorParams = healthmonitor_params()
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

        def update
          healthmonitorParams = healthmonitor_params()
          healthmonitor = services.lbaas2.find_healthmonitor(params[:id])
          # type is now inmutable
          healthmonitorParams[:type] = healthmonitor.type
          healthmonitor.update_attributes(healthmonitorParams)
          if healthmonitor.update
            audit_logger.info(current_user, 'has updated', healthmonitor)
            render json: healthmonitor
          else
            render json: {errors: healthmonitor.errors}, status: 422
          end
        rescue Elektron::Errors::ApiResponse => e
          render json: { errors: e.message }, status: e.code
        rescue Exception => e
          render json: { errors: e.message }, status: "500"
        end

        private

        def healthmonitor_params
          hp = params[:healthmonitor].to_unsafe_hash.symbolize_keys if params[:healthmonitor]
          unless (hp[:type] == 'HTTP' || hp[:type] == 'HTTPS')
            hp.delete(:url_path)
            hp.delete(:http_method)
            hp.delete(:expected_codes)
          end
          hp.delete_if{ |_k, v| v.blank?}
        end

      end
    end
  end
end
