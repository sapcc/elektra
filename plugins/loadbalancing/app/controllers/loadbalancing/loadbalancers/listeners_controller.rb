module Loadbalancing
  module Loadbalancers
    class ListenersController < DashboardController

      def index
        @loadbalancer = services.loadbalancing.find_loadbalancer(params[:loadbalancer_id])
        @listeners = services.loadbalancing.listeners({loadbalancer_id: params[:loadbalancer_id]})
        # @quota_data = services.resource_management.quota_data([
        #   {service_name: :loadbalancing, resource_name: :loadbalancers, usage: @loadbalancers.length},
        #   {service_name: :loadbalancing, resource_name: :loadbalancer_rules}
        # ])
      end


      def show
        #@loadbalancer = services.loadbalancing.find_loadbalancer(params[:loadbalancer_id])
        @listener = services.loadbalancing.find_listener(params[:id])
        @pools = [services.loadbalancing.find_pool(@listener.default_pool_id)] if @listener.default_pool_id
        # @quota_data = services.resource_management.quota_data([
        #                                                           {service_name: :networking, resource_name: :loadbalancers, usage: @loadbalancers.length},
        #                                                           {service_name: :networking, resource_name: :loadbalancer_rules, usage: @rules.length}
        #                                                       ])
      end

      def show_details
        @listener = services.loadbalancing.find_listener(params[:listener_id])
        @loadbalancer = services.loadbalancing.find_loadbalancer(@listener.loadbalancers.first['id'])
        @pool = services.loadbalancing.find_pool(@listener.default_pool_id) if @listener.default_pool_id
        @members = services.loadbalancing.pool_members(@pool.id) if @pool
        @healthmonitor = services.loadbalancing.find_healthmonitor(@pool.healthmonitor_id) if @pool and @pool.healthmonitor_id
      end

      def new
        @listener = services.loadbalancing.new_listener
        @loadbalancer = services.loadbalancing.find_loadbalancer(params[:loadbalancer_id])
      end

      def create
        @listener = services.loadbalancing.new_listener
        @loadbalancer = services.loadbalancing.find_loadbalancer(params[:loadbalancer_id])
        @listener.attributes = params[:listener].delete_if { |key, value| value.blank? }.merge(loadbalancer_id: @loadbalancer.id)

        if @listener.save
          audit_logger.info(current_user, "has created", @listener)
          redirect_to loadbalancer_listeners_path(loadbalancer_id: params[:loadbalancer_id]), notice: 'Listener successfully created.'
        else
          render :new
        end
      end

      def destroy
        @listener = services.loadbalancing.find_listener(params[:id])
        if @listener.destroy
          audit_logger.info(current_user, "has deleted", @listener)
          redirect_to loadbalancer_listeners_path(loadbalancer_id: @listener.loadbalancers.first['id']), notice: 'Listener successfully deleted.'
        else
          redirect_to loadbalancer_listeners_path(loadbalancer_id: @listener.loadbalancers.first['id']),
                      flash: { error: "Listener deletion failed -> #{@listener.errors.full_messages.to_sentence}" }
        end
      end

    end
  end
end
