module ServiceLayerNg
  # This module implements Openstack Domain API
  module Service
    
    def services(filter = {})
      debug "[compute-service][Service] -> services -> GET /os-services"
      api.compute.list_compute_services(filter).map_to(Compute::Service)
    end

    def disable_service_reason(host, name, disabled_reason)
      debug "[compute-service][Service] -> disable_service_reason -> PUT /os-services/disable-log-reason"
      api.compute.log_disabled_compute_service_information(
        "host"            => host,
        "binary"          => name, # I have no idea why that is called binary but name is better
        "disabled_reason" => disabled_reason
      )
    end

    def disable_service(host, name)
      debug "[compute-service][Service] -> disable_service -> PUT /os-services/disable"
      api.compute.disable_scheduling_for_a_compute_service(
        "host"   => host,
        "binary" => name # I have no idea why that is called binary but name is better
      )
    end

    def enable_service(host, name)
      debug "[compute-service][Service] -> enable_service -> PUT /os-services/enable"
      api.compute.enable_scheduling_for_a_compute_service(
        "host"   => host,
        "binary" => name # I have no idea why that is called binary but name is better
      )
    end

  end
end