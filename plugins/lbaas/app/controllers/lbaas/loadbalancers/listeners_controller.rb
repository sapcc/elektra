# frozen_string_literal: true

module Lbaas
  module Loadbalancers
    # listeners
    class ListenersController < ApplicationController
      before_action :load_objects, except: [:show]

      # set policy context
      authorization_context 'lbaas'
      # enforce permission checks. This will automatically investigate the rule name.
      authorization_required except: [:update_item]

      def index

        per_page = params[:per_page] || ENTRIES_PER_PAGE
        per_page = per_page.to_i
        @listeners = []
        loadbalancer_id = params[:loadbalancer_id]

        @listeners = paginatable(per_page: per_page) do |pagination_options|
          services.lbaas.listeners({loadbalancer_id: loadbalancer_id, sort_key: 'id'}.merge(pagination_options))
        end

        # this is relevant in case an ajax paginate call is made.
        # in this case we don't render the layout, only the list!
        if request.xhr?
          render partial: 'list', locals: { loadbalancer: @loadbalancer, listeners: @listeners }
        else
          # comon case, render index page with layout
          render action: :index
        end

      end

      def show
        @listener = services.lbaas.find_listener(params[:id])
        return unless @listener.default_pool_id
        @pool = services.lbaas.find_pool(@listener.default_pool_id)
      end

      def new
        @listener = services.lbaas.new_listener
        @pools = services.lbaas.pools(
          loadbalancer_id: @loadbalancer.id
        )
        @insert_headers = []
        containers = services.key_manager.containers(limit: 100)

        return unless containers
        @containers = containers[:items].map { |c| [c.name, c.container_ref] }
      end

      def create
        @listener = services.lbaas.new_listener
        @listener.attributes = listener_params.delete_if { |_key, value| value.blank? }.merge(loadbalancer_id: @loadbalancer.id)
        if @listener.save
          audit_logger.info(current_user, 'has created', @listener)
          redirect_to loadbalancer_listeners_path(loadbalancer_id: params[:loadbalancer_id]), notice: 'Listener successfully created.'
        else
          @insert_headers = @listener.protocol.blank? ? [] : Listener::INSERT_HEADERS[@listener.protocol]
          containers = services.key_manager.containers()
          if containers
            @containers = containers[:items].map { |c| [c.name, c.container_ref] }
          end
          @pools = services.lbaas.pools(loadbalancer_id: @loadbalancer.id)
          render :new
        end
      end

      def edit
        @listener = services.lbaas.find_listener(params[:id])
        @insert_headers = @listener.insert_headers.collect { |h| h[0] if h[1] == 'true'}.compact
        containers = services.key_manager.containers(limit: 100)
        if containers
          @containers = containers[:items].map { |c| [c.name, c.container_ref] }
        end
        @pools = services.lbaas.pools(loadbalancer_id: @loadbalancer.id)
      end

      def update
        @listener = services.lbaas.find_listener(params[:id])
        lparams = listener_params(@listener.protocol)
        lparams[:default_pool_id] = nil if lparams[:default_pool_id].blank? # only nil resets the default pool id
        if @listener.update(lparams)
          audit_logger.info(current_user, 'has updated', @listener)
          redirect_to loadbalancer_listeners_path(loadbalancer_id: @listener.loadbalancers.first['id']), notice: 'Listener was successfully updated.'
        else
          containers = services.key_manager.containers()
          if containers
            @containers = containers[:items].map { |c| [c.name, c.container_ref] }
          end
          @pools = services.lbaas.pools(loadbalancer_id: @loadbalancer.id)
          render :edit
        end
      end

      def destroy
        @listener = services.lbaas.find_listener(params[:id])
        @listener.destroy
        audit_logger.info(current_user, 'has deleted', @listener) if @listener.errors.blank?
        render template: 'lbaas/loadbalancers/listeners/destroy_item.js'
      end

      # update instance table row (ajax call)
      def update_item
        @listener = services.lbaas.find_listener(params[:id])
        @loadbalancer = services.lbaas.find_loadbalancer(params[:loadbalancer_id])
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
        @loadbalancer = services.lbaas.find_loadbalancer(params[:loadbalancer_id]) if params[:loadbalancer_id]
      end

      def listener_params(protocol = nil)
        p = params[:listener]
        # clear array with empty objects because backend can't deal with it
        p['sni_container_refs'].reject!(&:empty?)
        proto = p['protocol']
        if !proto and protocol
          proto = protocol
        end
        headers =  Lbaas::Listener::INSERT_HEADERS[proto]
        insert_headers = params[:listener][:insert_headers]
        octavia_headers = {}
        headers.each do |h|
          octavia_headers[h.to_sym] = insert_headers.include?(h) ? "true" : "false"
        end
        p[:insert_headers] = octavia_headers
        p[:tags] = get_tags p[:tags]
        return p
      end
    end
  end
end
