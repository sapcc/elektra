module Compute
  class HypervisorsController < Compute::ApplicationController
    before_action ->(id = params[:id] || params[:hypervisor_id]) { load_hv id }

    authorization_context 'compute'
    authorization_required

    def index
      @hypervisors = services.compute.hypervisors
    end

    def show
    end

    private

    def load_hv(id)
      @hypervisor = services.compute.find_hypervisor(id)
    end
  end
end
