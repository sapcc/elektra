module Loadbalancing
  module Loadbalancers
    class PoolsController < DashboardController

      before_filter :load_objects

      def index
        @loadbalancer = services.loadbalancing.find_loadbalancer(params[:loadbalancer_id])
        @pools = services.loadbalancing.pools({loadbalancer_id: params[:loadbalancer_id]})
        return @pools
      end

      def show_all
        @members = services.loadbalancing.pool_members(@pool.id) if @pool
        @healthmonitor = services.loadbalancing.find_healthmonitor(@pool.healthmonitor_id) if @pool and @pool.healthmonitor_id
        # @quota_data = services.resource_management.quota_data([
        #                                                           {service_name: 'networking', resource_name: 'loadbalancers', usage: @loadbalancers.length},
        #                                                           {service_name: 'networking', resource_name: 'loadbalancer_rules', usage: @rules.length}
        #                                                       ])
      end

      def show_details

        lb_id = nil
        if @pool.listeners.first['id']
          @listener = services.loadbalancing.find_listener(@pool.listeners.first['id'])
          lb_id = @listener.loadbalancers.first['id']
        elsif @pool.loadbalancers.first['id']
          lb_id = @pool.loadbalancers.first['id']
        end

        @loadbalancer = services.loadbalancing.find_loadbalancer(lb_id) if lb_id

        @members = services.loadbalancing.pool_members(@pool.id) if @pool
        begin
          @healthmonitor = services.loadbalancing.find_healthmonitor(@pool.healthmonitor_id) if @pool and @pool.healthmonitor_id
        rescue
          @healthmonitor = nil
        end

      end

      def new
        @pool = services.loadbalancing.new_pool
        @listeners = services.loadbalancing.listeners({loadbalancer_id: params[:loadbalancer_id]})
      end

      def create
        @pool = services.loadbalancing.new_pool
        @pool.attributes = pool_params.delete_if { |key, value| value.blank? }.merge(listener_id: pool_params[:listener_id]).merge(session_persistence)
        if @pool.save
          audit_logger.info(current_user, "has created", @pool)
#              render template: 'loadbalancing/loadbalancers/pools/update_item_with_close.js'
          redirect_to loadbalancer_pools_path(params[:loadbalancer_id]), notice: 'Pool was successfully created.'
        else
          @listeners = services.loadbalancing.listeners({loadbalancer_id: params[:loadbalancer_id]})
          render :new
        end
      end

      def edit
        @listeners = services.loadbalancing.listeners({loadbalancer_id: params[:loadbalancer_id]})
      end

      def update
        update_params = pool_params.merge!(session_persistence)
        @pool.listener_id = @pool.listeners.first['id']
        if @pool.update(update_params)
          @listeners = services.loadbalancing.listeners({loadbalancer_id: params[:loadbalancer_id]})
          @listener = services.loadbalancing.find_listener(@pool.listener_id) if @pool.listener_id
          @pool.listener = @listener if  @listener
          audit_logger.info(current_user, "has updated", @pool)
          render template: 'loadbalancing/loadbalancers/pools/update_item_with_close.js'
          #redirect_to pool_path(@pool.id), notice: 'Pool was successfully updated.'
        else
          render :edit
        end
      end

      def destroy
        @pool = services.loadbalancing.find_pool(params[:id])
        if @pool.destroy
          audit_logger.info(current_user, "has deleted", @pool)
          redirect_to loadbalancer_pools_path(params[:loadbalancer_id]), notice: 'Pool successfully deleted.'
        else
          redirect_to loadbalancer_pools_path(params[:loadbalancer_id]),
                      flash: {error: "Pool deletion failed -> #{@pool.errors.full_messages.to_sentence}"}
        end
      end

      private

      def load_objects
        @loadbalancer = services.loadbalancing.find_loadbalancer(params[:loadbalancer_id]) if params[:loadbalancer_id]
        @pool = services.loadbalancing.find_pool(params[:id]) if params[:id]
        @listener = services.loadbalancing.find_listener(@pool.listeners.first['id']) if @pool && @pool.listeners && @pool.listeners.first['id']
        @pool.listener = @listener if  @listener
      end

      def pool_params
        return params[:pool]
      end

      def session_persistence
        session_persistence = {session_persistence: {}}
        unless pool_params['session_persistence_type'].blank?
          session_persistence[:session_persistence].merge!({type: pool_params.delete('session_persistence_type')})
          if session_persistence[:session_persistence][:type] == 'APP_COOKIE'
            session_persistence[:session_persistence].merge!({cookie_name: pool_params.delete('session_persistence_cookie_name')})
          end
        end
        return session_persistence
      end

    end
  end
end
