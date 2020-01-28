# frozen_string_literal: true

module Lbaas2
  class LoadbalancersController < DashboardController
    def index
      # get paginated loadbalancers
      per_page = (params[:per_page] || 20).to_i
      pagination_options = { sort_key: 'name', sort_dir: 'asc', limit: per_page + 1 }
      pagination_options[:marker] = params[:marker] if params[:marker]
      loadbalancers = services.lbaas.loadbalancers({ project_id: @scoped_project_id}.merge(pagination_options))

      render json: {
        loadbalancers: loadbalancers,
        has_next: loadbalancers.length > per_page
      }
    rescue Elektron::Errors::ApiResponse => e
      render json: { errors: e.message }, status: e.code
    end
  end
end
