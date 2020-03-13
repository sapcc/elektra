# frozen_string_literal: true

module Lbaas2
  class LoadbalancersController < DashboardController
    def index
      # get paginated loadbalancers
      per_page = (params[:per_page] || 20).to_i
      pagination_options = { sort_key: 'name', sort_dir: 'asc', limit: per_page + 1 }
      pagination_options[:marker] = params[:marker] if params[:marker]
      loadbalancers = services.lbaas2.loadbalancers({ project_id: @scoped_project_id}.merge(pagination_options))

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
    
    def show
      loadbalancer = services.lbaas2.find_loadbalancer(params[:id])
      extend_lb_data([loadbalancer])

      render json: {
        loadbalancer: loadbalancer
      }
    rescue Elektron::Errors::ApiResponse => e
      render json: { errors: e.message }, status: e.code
    rescue Exception => e
      render json: { errors: e.message }, status: "500"
    end

    def destroy
      loadbalancer = services.lbaas2.new_loadbalancer
      loadbalancer.id = params[:id]

      if loadbalancer.destroy
        audit_logger.info(current_user, 'has deleted', loadbalancer)
        head 202
      else  
        render json: { errors: loadbalancer.errors }, status: 422
      end
    rescue Elektron::Errors::ApiResponse => e
      render json: { errors: e.message }, status: e.code
    rescue Exception => e
      render json: { errors: e.message }, status: "500"
    end

    def status_tree
      statuses = services.lbaas2.loadbalancer_statuses(params[:id])
      render json: {
        statuses: statuses
      }
    rescue Elektron::Errors::ApiResponse => e
      render json: { errors: e.message }, status: e.code
    rescue Exception => e
      render json: { errors: e.message }, status: "500"
    end

    def private_networks
      # get project networks
      private_networks = services.networking.project_networks(
        @scoped_project_id
      ).delete_if { |n| n.attributes['router:external'] == true }

      # transform data for a select input
      select_private_networks = private_networks.map {|pn| {"label": pn.name, "value": pn.id}}

      render json: { private_networks: select_private_networks }
    rescue Elektron::Errors::ApiResponse => e
      render json: { errors: e.message }, status: e.code
    rescue Exception => e
      render json: { errors: e.message }, status: "500"
    end    

    def subnets
      private_network = services.networking.find_network!(params[:id])
      subnets = private_network.subnet_objects || []
      select_subnets = subnets.map {|sb| {"label": "#{sb.name} (#{sb.cidr})", "value": sb.id}}

      render json: { subnets: select_subnets }
    rescue Elektron::Errors::ApiResponse => e
      render json: { errors: e.message }, status: e.code
    rescue Exception => e
      render json: { errors: e.message }, status: "500"
    end

    def create
      # add project id
      lbParams = params[:loadbalancer].merge(project_id: @scoped_project_id)
      loadbalancer = services.lbaas2.new_loadbalancer(lbParams)
      if loadbalancer.save
        audit_logger.info(current_user, 'has created', loadbalancer)
        # extend lb data with chached data
        extend_lb_data([loadbalancer])
        render json: loadbalancer
      else
        render json: {errors: loadbalancer.errors}, status: 422
      end
    rescue Elektron::Errors::ApiResponse => e
      render json: { errors: e.message }, status: e.code
    rescue Exception => e
      render json: { errors: e.message }, status: "500"
    end

    protected

    def extend_lb_data(lbs)
      # get project fips per api
      fips = services.networking.project_floating_ips(@scoped_project_id)

      # attach fips and subnets 
      lbs.each do |lb|
        # fips
        lb.floating_ip = fips.select{|fip| fip.port_id == lb.vip_port_id}.first
        # get subnet from cache if exists
        unless lb.vip_subnet_id.blank?
          lb.subnet_from_cache true
          lb.subnet = services.networking.cached_subnet(lb.vip_subnet_id)
          unless lb.subnet
            lb.subnet = services.networking.subnets(id: lb.vip_subnet_id).first
            lb.subnet_from_cache false
          end          
        end

        # get cached listeners
        lb.listeners = [] if lb.listeners.blank?
        lb.cached_listeners = ObjectCache.where(id: lb.listeners.map{|l| l[:id]}).each_with_object({}) do |l,map|
          map[l[:id]] = l
        end

        # get cached pools
        lb.pools = [] if lb.pools.blank?
        lb.cached_pools = ObjectCache.where(id: lb.pools.map{|p| p[:id]}).each_with_object({}) do |p,map|
          map[p[:id]] = p
        end

      end
    end
  end
end
