module Loadbalancing
  module Loadbalancers
    class ListenersController < DashboardController

      def index
        @loadbalancer = services.loadbalancing.find_loadbalancer(params[:loadbalancer_id])
        @listeners = services.loadbalancing.listeners({loadbalancer_id: params[:loadbalancer_id]})

        @quota_data = services.resource_management.quota_data([{service_name: :networking, resource_name: :listeners, usage: @listeners.length}])
      end


      def show
        #@loadbalancer = services.loadbalancing.find_loadbalancer(params[:loadbalancer_id])
        @listener = services.loadbalancing.find_listener(params[:id])
        @pools = [services.loadbalancing.find_pool(@listener.default_pool_id)] if @listener.default_pool_id
      end


      def new
        @listener = services.loadbalancing.new_listener
        @loadbalancer = services.loadbalancing.find_loadbalancer(params[:loadbalancer_id])
        containers = services.key_manager.containers()
        @containers = containers[:elements].map { |c| [c.name, c.container_ref] }  if containers
      end

      def create
        @listener = services.loadbalancing.new_listener
        @loadbalancer = services.loadbalancing.find_loadbalancer(params[:loadbalancer_id])
        @listener.attributes = params[:listener].delete_if { |key, value| value.blank? }.merge(loadbalancer_id: @loadbalancer.id)
        @listener.sni_container_refs.reject! { |c| c.empty? } if @listener.sni_container_refs
        if @listener.save
          audit_logger.info(current_user, "has created", @listener)
          redirect_to loadbalancer_listeners_path(loadbalancer_id: params[:loadbalancer_id]), notice: 'Listener successfully created.'
        else
          @loadbalancer = services.loadbalancing.find_loadbalancer(params[:loadbalancer_id])
          containers = services.key_manager.containers()
          @containers = containers[:elements].map { |c| [c.name, c.container_ref] }  if containers
          render :new
        end
      end

      def edit
        @listener = services.loadbalancing.find_listener(params[:id])
        @loadbalancer = services.loadbalancing.find_loadbalancer(params[:loadbalancer_id])
      end

      def update
        @listener = services.loadbalancing.find_listener(params[:id])
        # @listener.attributes = listener_params.delete_if { |key, value| value.blank? }
        if @listener.update(listener_params)
          audit_logger.info(current_user, "has updated", @listener)
          redirect_to loadbalancer_listeners_path(loadbalancer_id: @listener.loadbalancers.first['id'] ), notice: 'Listener was successfully updated.'
        else
          @loadbalancer = services.loadbalancing.find_loadbalancer(params[:loadbalancer_id])
          render :edit
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

      private

      def listener_params
        return params[:listener]
      end

    end
  end
end
