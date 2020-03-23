module Lbaas2
  module Loadbalancers
    module Listeners
      class L7policiesController < ApplicationController

        def index
          per_page = (params[:per_page] || 9999).to_i
          pagination_options = { sort_key: 'name', sort_dir: 'asc', limit: per_page + 1 }
          pagination_options[:marker] = params[:marker] if params[:marker]
          l7policies = services.lbaas2.l7policies({listener_id: params[:listener_id]}.merge(pagination_options)) # loadbalancer_id: params[:loadbalancer_id]

          render json: {
            l7policies: l7policies,
            has_next: l7policies.length > per_page
          }
        rescue Elektron::Errors::ApiResponse => e
          render json: { errors: e.message }, status: e.code
        rescue Exception => e
          render json: { errors: e.message }, status: "500"
        end

      end
    end
  end
end