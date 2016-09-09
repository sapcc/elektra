module Loadbalancing
  class LoadbalancersController < DashboardController
    def index
      @loadbalancers = services.loadbalancing.loadbalancers(tenant_id: @scoped_project_id)

      # @quota_data = services.resource_management.quota_data([
      #   {service_name: 'loadbalancing', resource_name: 'loadbalancers', usage: @loadbalancers.length},
      #   {service_name: 'loadbalancing', resource_name: 'loadbalancer_rules'}
      # ])
    end

    def show
      @loadbalancer = services.loadbalancing.find_loadbalancer(params[:id])
      # @quota_data = services.resource_management.quota_data([
      #                                                           {service_name: 'networking', resource_name: 'loadbalancers', usage: @loadbalancers.length},
      #                                                           {service_name: 'networking', resource_name: 'loadbalancer_rules', usage: @rules.length}
      #                                                       ])
    end

    def new
      @loadbalancer = services.loadbalancing.new_loadbalancer
      @private_networks   = services.networking.project_networks(@scoped_project_id).delete_if{|n| n.attributes["router:external"]==true} if services.networking.available?
    end

    def create
      @loadbalancer = services.loadbalancing.new_loadbalancer()
      @loadbalancer.attributes = loadbalancer_params.delete_if{ |key,value| value.blank?}

      if @loadbalancer.save
        audit_logger.info(current_user, "has created", @loadbalancer)
        redirect_to loadbalancers_path, notice: 'Load Balancer successfully created.'
      else
        @private_networks   = services.networking.project_networks(@scoped_project_id).delete_if{|n| n.attributes["router:external"]==true} if services.networking.available?
        render :new
      end

    end

    def destroy
      @loadbalancer = services.loadbalancing.find_loadbalancer(params[:id])
      if @loadbalancer.destroy
        audit_logger.info(current_user, "has deleted", @loadbalancer)
        flash.now[:error] = "Load Balancer will be deleted."
        redirect_to loadbalancers_path
      else
        flash.now[:error] = "Load Balancer deletion failerd."
        redirect_to loadbalancers_path
      end
    end

    private

    def loadbalancer_params
      return params[:loadbalancer].merge(tenant_id: @scoped_project_id)
    end

  end
end
