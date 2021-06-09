module Lbaas2
  module Loadbalancers
    module Pools
      class HealthmonitorsController < ::AjaxController
        authorization_context 'lbaas2'
        authorization_required
        
        def show
          healthmonitor = services.lbaas2.find_healthmonitor(params[:id])
          extend_healthmonitor_data(healthmonitor)
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
          healthmonitor = services.lbaas2.new_healthmonitor(newParams)

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
          healthmonitor = services.lbaas2.new_healthmonitor(healthmonitorParams)

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

        def destroy
          healthmonitor = services.lbaas2.new_healthmonitor
          healthmonitor.id = params[:id]

          if healthmonitor.destroy
            audit_logger.info(current_user, 'has deleted', healthmonitor)
            head 202
          else
            render json: { errors: healthmonitor.errors }, status: 422
          end
        rescue Elektron::Errors::ApiResponse => e
          render json: { errors: e.message }, status: e.code
        rescue Exception => e
          render json: { errors: e.message }, status: "500"
        end

        private

        def extend_healthmonitor_data(healthmonitor)         
          vip_port_id = params[:vip_port_id]
          if vip_port_id.blank?
            # fetch first the loadbalancer
            loadbalancer = services.lbaas2.find_loadbalancer(params[:loadbalancer_id])
            vip_port_id = loadbalancer.vip_port_id
          end
          # call to newtron to get the ips
          port = services.networking.find_port(vip_port_id)
          if port && port.allowed_address_pairs
            healthmonitor.allowed_address_pairs = port.allowed_address_pairs
          end
        end

        def healthmonitor_params
          hp = params[:healthmonitor].to_unsafe_hash.symbolize_keys if params[:healthmonitor]
          hp[:max_retries] = hp[:max_retries].to_i unless hp[:max_retries].blank?
          hp[:delay] = hp[:delay].to_i unless hp[:delay].blank?
          hp[:timeout] = hp[:timeout].to_i unless hp[:timeout].blank?
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
