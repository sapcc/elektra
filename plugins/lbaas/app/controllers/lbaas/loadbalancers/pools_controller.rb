# frozen_string_literal: true

module Lbaas
  module Loadbalancers
    class PoolsController < ApplicationController
      before_action :load_objects

      # set policy context
      authorization_context 'lbaas'
      # enforce permission checks. This will automatically investigate
      # the rule name.
      authorization_required except: %i[show_all show_details]

      def index
        per_page = params[:per_page] || ENTRIES_PER_PAGE
        per_page = per_page.to_i
        @pools = []
        loadbalancer_id = params[:loadbalancer_id]

        @pools = paginatable(per_page: per_page) do |pagination_options|
          services.lbaas.pools({loadbalancer_id: loadbalancer_id, sort_key: 'id'}.merge(pagination_options))
        end

        # this is relevant in case an ajax paginate call is made.
        # in this case we don't render the layout, only the list!
        if request.xhr?
          render partial: 'list', locals: { loadbalancer: @loadbalancer, pools: @pools }
        else
          # comon case, render index page with layout
          render action: :index
        end

      end

      def show_all
        enforce_permissions('lbaas:pool_get')

        @members = services.lbaas.pool_members(@pool.id) if @pool

        if @pool && @pool.healthmonitor_id
          @healthmonitor = services.lbaas.find_healthmonitor(@pool.healthmonitor_id)
        end
      end

      def show_details
        enforce_permissions('lbaas:pool_get')

        @members = services.lbaas.pool_members(@pool.id) if @pool
        begin
          @healthmonitor = services.lbaas.find_healthmonitor(@pool.healthmonitor_id) if @pool and @pool.healthmonitor_id
        rescue
          @healthmonitor = nil
        end
      end

      def new
        @pool = services.lbaas.new_pool
        @listeners = services.lbaas.listeners({loadbalancer_id: params[:loadbalancer_id]}).keep_if { |l| l.default_pool_id.blank? }
        if params[:listener_id]
          @pool.listener_id = params[:listener_id]
        end
        @pool.loadbalancer_id = @loadbalancer.id
        @pool.protocol = params[:proto] if params[:proto] && params[:proto] != 'TERMINATED_HTTPS'
        @pool.protocol = 'HTTP' if params[:proto] && params[:proto] == 'TERMINATED_HTTPS'
        @protocols = @pool.protocol.blank? ? Lbaas::Pool::PROTOCOLS : [@pool.protocol]
        containers = services.key_manager.containers(limit: 100)
        return unless containers
        @containers = containers[:items].map { |c| [c.name, c.container_ref] }
      end

      def create
        @pool = services.lbaas.new_pool
        @pool.attributes = pool_params.merge(session_persistence)
        @pool.loadbalancer_id = params[:loadbalancer_id]
        if @pool.save
          audit_logger.info(current_user, 'has created', @pool)
          # render template: 'lbaas/loadbalancers/pools/update_item_with_close.js'
          redirect_to loadbalancer_pools_path(loadbalancer_id: @loadbalancer.id), notice: 'Pool was successfully created.'
        else
          @pool.loadbalancer_id = @loadbalancer.id
          @protocols = @pool.listener_id.blank? ? Lbaas::Pool::PROTOCOLS : [@pool.protocol]
          @listeners = services.lbaas.listeners({loadbalancer_id: params[:loadbalancer_id]}).keep_if { |l| l.default_pool_id.blank? }
          render :new
        end
      end

      def edit
        @listeners = services.lbaas.listeners({loadbalancer_id: params[:loadbalancer_id]})
        @protocols = @pool.listener_id.blank? ? Lbaas::Pool::PROTOCOLS : [@pool.protocol]
        containers = services.key_manager.containers(limit: 100)
        return unless containers
        @containers = containers[:items].map { |c| [c.name, c.container_ref] }
      end

      def update
        update_params = pool_params.merge!(session_persistence)
        if @pool.update(update_params)
          audit_logger.info(current_user, 'has updated', @pool)
          render template: 'lbaas/loadbalancers/pools/update_item_with_close.js'
        else
          @listeners = services.lbaas.listeners({loadbalancer_id: params[:loadbalancer_id]})
          @protocols = @pool.listener_id.blank? ? Lbaas::Pool::PROTOCOLS : [@pool.protocol]
          render :edit
        end
      end

      def destroy
        @pool = services.lbaas.find_pool(params[:id])
        if @pool.healthmonitor_id
          @healthmonitor = services.lbaas.find_healthmonitor(
            @pool.healthmonitor_id
          )
        end


        if @healthmonitor
          unless services.lbaas.execute(params[:loadbalancer_id]) {@healthmonitor.destroy}
            redirect_to loadbalancer_pools_path(loadbalancer_id: @loadbalancer.id),
                        flash: {error: "Could not delete attached Healthmonitor #{@healthmonitor.errors.full_messages.to_sentence}"} and return
          end
        end

        pool_deleted = true
        pool_deleted = services.lbaas.execute(params[:loadbalancer_id]) {@pool.destroy} if @pool

        if pool_deleted and @healthmonitor
          audit_logger.info(current_user, "has deleted", @pool)
          audit_logger.info(current_user, "has deleted", @healthmonitor)
          redirect_to request.referer, notice: 'Pool and Healthmonitor will be deleted.'
        elsif pool_deleted && !@healthmonitor
          audit_logger.info(current_user, "has deleted", @pool)
          redirect_to request.referer, notice: 'Pool will be deleted.'
        else
          redirect_to request.referer, flash: {error: "Pool deletion failed -> #{@pool.errors.full_messages.to_sentence}"}
        end
      end

      private

      def load_objects
        @pool = services.lbaas.find_pool(params[:id]) if params[:id]
        if params[:loadbalancer_id]
          @loadbalancer = services.lbaas.find_loadbalancer(
            params[:loadbalancer_id]
          )
        end
        return unless @pool

        if @pool.listeners.first
          @listener = services.lbaas.find_listener(
            @pool.listeners.first['id']
          )
        end
        @pool.listener_id = @listener.id if @listener
        @pool.loadbalancer_id = @loadbalancer.id
      end

      def pool_params
        p = params[:pool]
        p[:tags] = get_tags p[:tags]
        return p
      end

      def session_persistence
        session_persistence = { session_persistence: {} }
        unless pool_params['session_persistence_type'].blank?
          session_persistence[:session_persistence][:type] =
            pool_params.delete('session_persistence_type')
          if session_persistence[:session_persistence][:type] == 'APP_COOKIE'
            session_persistence[:session_persistence][:cookie_name] =
              pool_params.delete('session_persistence_cookie_name')
          end
        end
        session_persistence
      end
    end
  end
end
