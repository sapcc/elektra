module Compute
  class HypervisorsController < Compute::ApplicationController
    authorization_context 'compute'
    authorization_required

    def index
      @hypervisors = services.compute.hypervisors
    end

    # def show
    #   @hypervisor = services.compute.find_hypervisor(params[:id])
    # end

    # def servers
    #   @servers = services.compute.hypervisor_servers(params[:id])
    # end

    private

    def release_state
      'experimental'
    end
  end
end
