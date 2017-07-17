module Compute
  class ServicesController < Compute::ApplicationController
    authorization_context 'compute'
    authorization_required

    def index
      compute_services = services_ng.compute.services(binary: 'nova-compute')
      @compute_services = compute_services.sort_by(&:zone) if compute_services
    end

    def enable
      host = params['id']
      services_ng.compute.enable_service(host, 'nova-compute')
      redirect_to services_url
    end

    def disable
      host = params['id']
      services_ng.compute.disable_service(host, 'nova-compute')
      redirect_to services_url
    end

    def edit
      @service = Compute::Service.new(nil, id: params['id'], reason: params['reason'])
    end

    def update
      host = params['id']
      reason = params['service']['reason']
      if services_ng.compute.disable_service_reason(host, 'nova-compute', reason)
        redirect_to services_url
      else
        render :edit
      end
    end

    private

    def release_state
      'experimental'
    end
  end
end
