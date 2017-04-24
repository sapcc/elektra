module Loadbalancing
  module Loadbalancers
    class ListenersController < DashboardController

      before_filter :load_objects, except: [:show]

      def index
        @listeners = services.loadbalancing.listeners({loadbalancer_id: params[:loadbalancer_id]})
        @quota_data = services.resource_management.quota_data([{service_type: :network, resource_name: :listeners,
                                                                usage: services.loadbalancing.listeners(tenant_id: @scoped_project_id).length}])
      end


      def show
        @listener = services.loadbalancing.find_listener(params[:id])
        @pools = [services.loadbalancing.find_pool(@listener.default_pool_id)] if @listener.default_pool_id
      end


      def new
        @listener = services.loadbalancing.new_listener
        containers = services.key_manager.containers()
        @containers = containers[:elements].map { |c| [c.name, c.container_ref] } if containers
      end

      def create
        @listener = services.loadbalancing.new_listener
        @listener.attributes = listener_params.delete_if { |key, value| value.blank? }.merge(loadbalancer_id: @loadbalancer.id)
        if @listener.save
          audit_logger.info(current_user, "has created", @listener)
          redirect_to loadbalancer_listeners_path(loadbalancer_id: params[:loadbalancer_id]), notice: 'Listener successfully created.'
        else
          containers = services.key_manager.containers()
          @containers = containers[:elements].map { |c| [c.name, c.container_ref] } if containers
          render :new
        end
      end

      def edit
        @listener = services.loadbalancing.find_listener(params[:id])
        containers = services.key_manager.containers()
        @containers = containers[:elements].map { |c| [c.name, c.container_ref] } if containers
      end

      def update
        @listener = services.loadbalancing.find_listener(params[:id])
        if @listener.update(listener_params)
          audit_logger.info(current_user, "has updated", @listener)
          redirect_to loadbalancer_listeners_path(loadbalancer_id: @listener.loadbalancers.first['id']), notice: 'Listener was successfully updated.'
        else
          containers = services.key_manager.containers()
          @containers = containers[:elements].map { |c| [c.name, c.container_ref] } if containers
          render :edit
        end
      end


      def destroy
        @listener = services.loadbalancing.find_listener(params[:id])
        @listener.destroy
        audit_logger.info(current_user, "has deleted", @listener)
        render template: 'loadbalancing/loadbalancers/listeners/destroy_item.js'
      end

      # update instance table row (ajax call)
      def update_item
        begin
          @listener = services.loadbalancing.find_listener(params[:id])
          @loadbalancer = services.loadbalancing.find_loadbalancer(params[:loadbalancer_id])
          respond_to do |format|
            format.js do
              @listener if @listener
            end
          end
        rescue => e
          return nil
        end
      end


      private

      def load_objects
        @loadbalancer = services.loadbalancing.find_loadbalancer(params[:loadbalancer_id]) if params[:loadbalancer_id]
      end


      def listener_params
        p = params[:listener]
        # clear array with empty objects because backend can't deal with it
        p['sni_container_refs'].reject! { |c| c.empty? }
       return p
      end

    end
  end
end
