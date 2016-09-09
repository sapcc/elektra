module Loadbalancing
  module Loadbalancers
    module Listeners
      module Pools
        class HealthmonitorsController < DashboardController

          #before_action :load_objects

          def new
            @pool = services.loadbalancing.find_pool(params[:pool_id])
            @healthmonitor = services.loadbalancing.new_healthmonitor
            @healthmonitor.http_method = 'GET'
            @healthmonitor.expected_codes = "200"
            @healthmonitor.url_path = '/'
          end

          def create
            @pool = services.loadbalancing.find_pool(params[:pool_id])
            @healthmonitor = services.loadbalancing.new_healthmonitor
            @healthmonitor.attributes = healthmonitor_params.delete_if { |key, value| value.blank? }.merge(pool_id: params[:pool_id])

            if @healthmonitor.save
              audit_logger.info(current_user, "has created", @healthmonitor)
              listener_id = @pool.listeners.first['id']
              redirect_to listener_show_details_path(listener_id), notice: 'Healthmonitor was successfully created.'
            else
              render :new
            end
          end

          def edit
            @healthmonitor = services.loadbalancing.find_healthmonitor(params[:id])
          end

          def update
            @healthmonitor = services.loadbalancing.find_healthmonitor(params[:id])
            if @healthmonitor.update(healthmonitor_params)
              audit_logger.info(current_user, "has updated", @healthmonitor)
              render template: 'loadbalancing/loadbalancers/listeners/pools/healthmonitors/update_item_with_close.js'
            else
              render :edit
            end
          end

          def destroy
            @healthmonitor = services.loadbalancing.find_healthmonitor(params[:id])
            pool = services.loadbalancing.find_pool(@healthmonitor.pools.first['id'])
            listener_id = pool.listeners.first['id']
            if @healthmonitor.destroy
              audit_logger.info(current_user, "has deleted", @healthmonitor)
              redirect_to listener_show_details_path(listener_id), notice: 'Health Monitor successfully deleted.'
            else
              redirect_to listener_show_details_path(listener_id),
                          flash: {error: "Health Monitor  deletion failed -> #{@healthmonitor.errors.full_messages.to_sentence}"}
            end
          end


          private

          def load_objects
            @loadbalancer = services.loadbalancing.find_loadbalancer(params[:loadbalancer_id]) if params[:loadbalancer_id]
            @listener = services.loadbalancing.find_listener(params[:listener_id]) if params[:listener_id]
            @healthmonitor = services.loadbalancing.find_healthmonitor(params[:id]) if params[:id]
          end

          def healthmonitor_params
            p = params[:healthmonitor].symbolize_keys if params[:healthmonitor]
            unless p[:type] == 'HTTP'
              p.delete(:url_path)
              p.delete(:http_method)
              p.delete(:expected_codes)
            end
            return p
          end

        end
      end
    end
  end
end
