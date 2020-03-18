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

    end
  end
end