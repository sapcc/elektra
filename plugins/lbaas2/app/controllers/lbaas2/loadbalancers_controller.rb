# frozen_string_literal: true

module Lbaas2
  class LoadbalancersController < DashboardController
    def index
      # get paginated loadbalancers
      per_page = (params[:per_page] || 20).to_i
      pagination_options = { sort_key: 'name', sort_dir: 'asc', limit: per_page + 1 }
      pagination_options[:marker] = params[:marker] if params[:marker]
      loadbalancers = services.lbaas.loadbalancers({ project_id: @scoped_project_id}.merge(pagination_options))

      # add fips and subnets to the lb objects
      fips = services.networking.project_floating_ips(@scoped_project_id)
      loadbalancers.each do |lb|
        lb.floating_ip = fips.select{|fip| fip.port_id == lb.vip_port_id}.first
        lb.subnet = services.networking.cached_subnet(lb.vip_subnet_id)
      end

      render json: {
        loadbalancers: loadbalancers,
        has_next: loadbalancers.length > per_page
      }
    rescue Elektron::Errors::ApiResponse => e
      render json: { errors: e.message }, status: e.code
    end
  end
end
