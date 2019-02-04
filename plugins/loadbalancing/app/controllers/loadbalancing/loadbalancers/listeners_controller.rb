# frozen_string_literal: true

module Loadbalancing
  module Loadbalancers
    # listeners
    class ListenersController < ApplicationController
      before_action :load_objects, except: [:show]

      # set policy context
      authorization_context 'loadbalancing'
      # enforce permission checks. This will automatically investigate the rule name.
      authorization_required except: [:update_item]

      def index
        @listeners = services.loadbalancing.listeners(
          loadbalancer_id: params[:loadbalancer_id]
        )
        @quota_data = []
        return unless current_user.is_allowed?('access_to_project')
        @quota_data = services.resource_management.quota_data(
          current_user.domain_id || current_user.project_domain_id,
          current_user.project_id,
          [
            {
              service_type: :network, resource_name: :listeners,
              usage: services.loadbalancing.listeners(
                tenant_id: @scoped_project_id
              ).length
            }
          ]
        )
      end

      def show
        @listener = services.loadbalancing.find_listener(params[:id])
        return unless @listener.default_pool_id
        @pool = services.loadbalancing.find_pool(@listener.default_pool_id)
      end

      def new
        @listener = services.loadbalancing.new_listener
        @pools = services.loadbalancing.pools(
          loadbalancer_id: @loadbalancer.id
        )
        containers = services.key_manager.containers(limit: 100)

        return unless containers
        @containers = containers[:items].map { |c| [c.name, c.container_ref] }
      end

      def create
        @listener = services.loadbalancing.new_listener
        @listener.attributes = listener_params.delete_if { |_key, value| value.blank? }.merge(loadbalancer_id: @loadbalancer.id)
        if @listener.save
          audit_logger.info(current_user, 'has created', @listener)
          redirect_to loadbalancer_listeners_path(loadbalancer_id: params[:loadbalancer_id]), notice: 'Listener successfully created.'
        else
          containers = services.key_manager.containers()
          if containers
            @containers = containers[:items].map { |c| [c.name, c.container_ref] }
          end
          @pools = services.loadbalancing.pools(loadbalancer_id: @loadbalancer.id)
          render :new
        end
      end

      def edit
        @listener = services.loadbalancing.find_listener(params[:id])
        containers = services.key_manager.containers(limit: 100)
        if containers
          @containers = containers[:items].map { |c| [c.name, c.container_ref] }
        end
        @pools = services.loadbalancing.pools(loadbalancer_id: @loadbalancer.id)
      end

      def update
        @listener = services.loadbalancing.find_listener(params[:id])
        lparams = listener_params
        lparams[:default_pool_id] = nil if lparams[:default_pool_id].blank? # only nil resets the default pool id
        if @listener.update(listener_params)
          audit_logger.info(current_user, 'has updated', @listener)
          redirect_to loadbalancer_listeners_path(loadbalancer_id: @listener.loadbalancers.first['id']), notice: 'Listener was successfully updated.'
        else
          containers = services.key_manager.containers()
          if containers
            @containers = containers[:items].map { |c| [c.name, c.container_ref] }
          end
          @pools = services.loadbalancing.pools(loadbalancer_id: @loadbalancer.id)
          render :edit
        end
      end

      def destroy
        @listener = services.loadbalancing.find_listener(params[:id])
        @listener.destroy
        audit_logger.info(current_user, 'has deleted', @listener)
        render template: 'loadbalancing/loadbalancers/listeners/destroy_item.js'
      end

      # update instance table row (ajax call)
      def update_item
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

      private

      def load_objects
        @loadbalancer = services.loadbalancing.find_loadbalancer(params[:loadbalancer_id]) if params[:loadbalancer_id]
      end

      def listener_params
        p = params[:listener]
        # clear array with empty objects because backend can't deal with it
        p['sni_container_refs'].reject!(&:empty?)
        p
      end
    end
  end
end
