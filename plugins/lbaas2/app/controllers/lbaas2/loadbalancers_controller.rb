# frozen_string_literal: true

module Lbaas2
  class LoadbalancersController < DashboardController
    def index
      # get paginated loadbalancers
      per_page = (params[:per_page] || 20).to_i
      pagination_options = { sort_key: 'name', sort_dir: 'asc', limit: per_page + 1 }
      pagination_options[:marker] = params[:marker] if params[:marker]
      loadbalancers = services.lbaas.loadbalancers({ project_id: @scoped_project_id}.merge(pagination_options))

      extend_lb_data(loadbalancers)

      render json: {
        loadbalancers: loadbalancers,
        has_next: loadbalancers.length > per_page
      }
    rescue Elektron::Errors::ApiResponse => e
      render json: { errors: e.message }, status: e.code
    rescue Exception => e
      render json: { errors: e.message }, status: "500"
    end

    def status_tree
      statuses = services.lbaas.loadbalancer_statuses(params[:id])
      render json: {
        statuses: statuses
      }
    end

    protected

    def extend_lb_data(lbs)
      # get project fips per api
      fips = services.networking.project_floating_ips(@scoped_project_id)

      # attach fips and subnets 
      lbs.each do |lb|
        # fips
        lb.floating_ip = fips.select{|fip| fip.port_id == lb.vip_port_id}.first
        # subnet
        unless lb.vip_subnet_id.blank?
          lb.subnet_from_cache true
          lb.subnet = services.networking.cached_subnet(lb.vip_subnet_id)
          unless lb.subnet
            lb.subnet = services.networking.subnets(id: lb.vip_subnet_id).first
            lb.subnet_from_cache false
          end          
        end

        # get cached listeners
        unless lb.listeners.blank?
          lb.cached_listeners = ObjectCache.where(id: lb.listeners.map{|l| l[:id]}).each_with_object({}) do |l,map|
            map[l[:id]] = l
          end
        end

        # get cached pools
        unless lb.pools.blank?
          lb.cached_pools = ObjectCache.where(id: lb.pools.map{|p| p[:id]}).each_with_object({}) do |p,map|
            map[p[:id]] = p
          end
        end

      end
    end
  end
end
