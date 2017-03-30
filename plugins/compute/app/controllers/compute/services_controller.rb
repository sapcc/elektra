module Compute
  class ServicesController < Compute::ApplicationController
    authorization_context 'compute'
    authorization_required

    def index
      @compute_services = services.compute.services(binary: 'nova-compute')
    end

    def enable
      host = params['id']
      services.compute.driver.enable_service(host, 'nova-compute')
      redirect_to services_url
    end

    def disable
      host = params['id']
      services.compute.driver.disable_service(host, 'nova-compute')
      redirect_to services_url
    end

    def edit
      @service = Compute::Service.new(nil, id: params['id'])
    end

    def update
      host = params['id']
      reason = params['service']['reason']
      if services.compute.driver.disable_service_reason(host, 'nova-compute', reason)
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
