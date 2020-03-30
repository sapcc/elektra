# frozen_string_literal: true

module Lbaas2
  module Loadbalancers
    class ListenersController < DashboardController

      def index
        per_page = (params[:per_page] || 20).to_i
        pagination_options = { sort_key: 'name', sort_dir: 'asc', limit: per_page + 1 }
        pagination_options[:marker] = params[:marker] if params[:marker]
        listeners = services.lbaas2.listeners({ loadbalancer_id: params[:loadbalancer_id]}.merge(pagination_options))

        render json: {
          listeners: listeners,
          has_next: listeners.length > per_page
        }
      rescue Elektron::Errors::ApiResponse => e
        render json: { errors: e.message }, status: e.code
      rescue Exception => e
        render json: { errors: e.message }, status: "500"
      end

      def show
        listener = services.lbaas2.find_listener(params[:id])
        render json: {
          listener: listener
        }
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

    end
  end
end