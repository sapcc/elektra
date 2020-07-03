# frozen_string_literal: true

module Lbaas2
  module Loadbalancers
    class ListenersController < DashboardController
      authorization_context 'lbaas2'
      authorization_required

      def index
        limit = (params[:limit] || 9).to_i
        sort_key = (params[:sort_key] || 'name')
        sort_dir = (params[:sort_dir] || 'asc')
        pagination_options = { sort_key: sort_key, sort_dir: sort_dir, limit: limit + 1 }
        pagination_options[:marker] = params[:marker] if params[:marker]
        listeners = services.lbaas2.listeners({ loadbalancer_id: params[:loadbalancer_id]}.merge(pagination_options))
        # extend listener data with chached data
        extend_listener_data(listeners)

        render json: {
          listeners: listeners,
          has_next: listeners.length > limit,
          limit: limit, sort_key: sort_key, sort_dir: sort_dir
        }
      rescue Elektron::Errors::ApiResponse => e
        render json: { errors: e.message }, status: e.code
      rescue Exception => e
        render json: { errors: e.message }, status: "500"
      end

      def show
        listener = services.lbaas2.find_listener(params[:id])
        # extend listener data with chached data
        extend_listener_data([listener])
        render json: {
          listener: listener
        }
      rescue Elektron::Errors::ApiResponse => e
        render json: { errors: e.message }, status: e.code
      rescue Exception => e
        render json: { errors: e.message }, status: "500"
      end   

      def create
        # add project id and filter params
        newParams = parseListenerParams.merge(project_id: @scoped_project_id, loadbalancer_id: params[:loadbalancer_id])
        listener = services.lbaas2.new_listener(newParams)
        if listener.save
          audit_logger.info(current_user, 'has created', listener)
          render json: listener
        else
          render json: {errors: listener.errors}, status: 422
        end
      rescue Elektron::Errors::ApiResponse => e
        render json: { errors: e.message }, status: e.code
      rescue Exception => e
        render json: { errors: e.message }, status: "500"
      end

      def update
        newParams = parseListenerParams
        listener = services.lbaas2.find_listener(params[:id])
  
        listener.update_attributes(newParams)
        if listener.update
          audit_logger.info(current_user, 'has updated', listener)
          render json: listener
        else
          render json: {errors: listener.errors}, status: 422
        end
      rescue Elektron::Errors::ApiResponse => e
        render json: { errors: e.message }, status: e.code
      rescue Exception => e
        render json: { errors: e.message }, status: "500"
      end

      def destroy
        listener = services.lbaas2.new_listener
        listener.id = params[:id]
  
        if listener.destroy
          audit_logger.info(current_user, 'has deleted', listener)
          head 202
        else  
          render json: { errors: listener.errors }, status: 422
        end
      rescue Elektron::Errors::ApiResponse => e
        render json: { errors: e.message }, status: e.code
      rescue Exception => e
        render json: { errors: e.message }, status: "500"
      end

      def containers
        containers = services.key_manager.containers(limit: 100)
        containers = {items: []} if containers.blank?
        selectContainers = containers[:items].map { |c| {"label": "#{c.name} (#{c.id})", "value": c.container_ref} }
        
        render json: {
          containers: selectContainers
        }
      rescue Exception => e
        render json: { errors: e.message }, status: "500"
      end

      def itemsWithoutDefaultPoolForSelect
        listeners = services.lbaas2.listeners({loadbalancer_id: params[:loadbalancer_id]}).keep_if { |l| l.default_pool_id.blank? }
        select_listeners = listeners.map {|listener| {"label": "#{listener.name || listener.id} (#{listener.protocol})", "value": listener.id, protocol: listener.protocol}}

        render json: { listeners: select_listeners }
      rescue Elektron::Errors::ApiResponse => e
        render json: { errors: e.message }, status: e.code
      rescue Exception => e
        render json: { errors: e.message }, status: "500"
      end

      protected

      def extend_listener_data(listeners)
        listeners.each do |listener|
          # get cached listeners
          listener.l7policies = [] if listener.l7policies.blank?
          listener.cached_l7policies = ObjectCache.where(id: listener.l7policies.map{|l| l[:id]}).each_with_object({}) do |l,map|
            map[l[:id]] = l
          end

          # get insert headers with true value
          listener.insert_headers = {} if  listener.insert_headers.blank?
          listener.insert_headers_keys = listener.insert_headers.select{|key, value| value == "true"}.keys
        end
      end

      def parseListenerParams()
        listenerParams = params[:listener]
        # clear array with empty objects because backend can't deal with it
        listenerParams['sni_container_refs'].reject!(&:empty?) unless listenerParams['sni_container_refs'].blank?
        # add boolean strings to the insert headers
        insert_headers = listenerParams[:insert_headers] || []
        octavia_headers = {}
        insert_headers.each do |h|        
          octavia_headers[h.to_sym] = "true"
        end
        listenerParams[:insert_headers] = octavia_headers
        return listenerParams
      end

    end
  end
end