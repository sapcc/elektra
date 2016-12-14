module Loadbalancing
  module Loadbalancers
    module Pools
      class HealthmonitorsController < DashboardController

        before_filter :load_objects

        def new
          @healthmonitor = services.loadbalancing.new_healthmonitor
          @healthmonitor.http_method = 'GET'
          @healthmonitor.expected_codes = "200"
          @healthmonitor.url_path = '/'
        end

        def create
          @healthmonitor = services.loadbalancing.new_healthmonitor
          @healthmonitor.attributes = healthmonitor_params.delete_if { |key, value| value.blank? }.merge(pool_id: params[:pool_id])

          if @healthmonitor.save
            audit_logger.info(current_user, "has created", @healthmonitor)
            render template: 'loadbalancing/loadbalancers/pools/healthmonitors/update_item_with_close.js'
            #redirect_to show_details_pool_path(@pool.id), notice: 'Healthmonitor was successfully created.'
          else
            render :new
          end
        end

        def edit
        end

        def update
          params[:healthmonitor][:type] = @healthmonitor.type
          if @healthmonitor.update(healthmonitor_params)
            audit_logger.info(current_user, "has updated", @healthmonitor)
            render template: 'loadbalancing/loadbalancers/pools/healthmonitors/update_item_with_close.js'
          else
            @pool = services.loadbalancing.find_pool(params[:pool_id])
            render :edit
          end
        end

        def destroy
          if @healthmonitor.destroy
            audit_logger.info(current_user, "has deleted", @healthmonitor)
            @healthmonitor = nil
            render template: 'loadbalancing/loadbalancers/pools/healthmonitors/update_item_with_close.js'
            #redirect_to show_details_pool_path(pool.id), notice: 'Health Monitor successfully deleted.'
          else
            redirect_to show_details_loadbalancer_pool_path(pool.id),
                        flash: {error: "Health Monitor  deletion failed -> #{@healthmonitor.errors.full_messages.to_sentence}"}
          end
        end


        private

        def load_objects
          @loadbalancer = services.loadbalancing.find_loadbalancer(params[:loadbalancer_id]) if params[:loadbalancer_id]
          @pool = services.loadbalancing.find_pool(params[:pool_id]) if params[:pool_id]
          @healthmonitor = services.loadbalancing.find_healthmonitor(params[:id]) if params[:id]
        end

        def healthmonitor_params
          p = params[:healthmonitor].symbolize_keys if params[:healthmonitor]
          unless (p[:type] == 'HTTP' || p[:type] == 'HTTPS')
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
