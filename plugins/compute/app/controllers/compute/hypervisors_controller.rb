module Compute
  class HypervisorsController < Compute::ApplicationController
    before_action ->(id = params[:id] || params[:hypervisor_id]) { load_hv id }

    authorization_context 'compute'
    authorization_required

    def index
      @hypervisors = services_ng.compute.hypervisors
    end

    def show
    end

    private

    def release_state
      'experimental'
    end

    def load_hv(id)
      @hypervisor = services_ng.compute.find_hypervisor(id)
    end
  end
end
