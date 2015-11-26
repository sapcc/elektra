module ResourceManagement
  class Resource < ActiveRecord::Base
    #validates [:service, :name], presence: true

    KNOWN_SERVICES = [
      # "service" is the service from which we pull this resource.
      # "area" identifies the tab in which to display resources for this service.
      # If "enabled" is false, no data will be gathered and the service will be hidden from the UI.
      # (This can be used to restrict unfinished service bindings to development mode, or to
      # activate capabilities based on the available OpenStack services in the service catalog.)
      { service: :compute,        area: :compute, enabled: Rails.env.development? },
      { service: :network,        area: :network, enabled: Rails.env.development? },
      { service: :block_storage,  area: :storage, enabled: Rails.env.development? },
      { service: :object_storage, area: :storage, enabled: true },
    ]

    KNOWN_RESOURCES = [
      # "name" identifies the resource within its service.
      # "service" identifies the service from which we pull this resource.
      { service: :compute,        name: :cores           },
      { service: :compute,        name: :instances       },
      { service: :compute,        name: :ram             },
      { service: :network,        name: :floating_ips    },
      { service: :network,        name: :networks        },
      { service: :network,        name: :ports           },
      { service: :network,        name: :routers         },
      { service: :network,        name: :security_groups },
      { service: :network,        name: :subnets         },
      { service: :block_storage,  name: :capacity,       display_unit: 1 << 30 }, # stored in bytes, displayed in GiB
      { service: :block_storage,  name: :snapshots       },
      { service: :block_storage,  name: :volumes         },
      { service: :object_storage, name: :capacity,       display_unit: 1 << 30 }, # stored in bytes, displayed in GiB
    ]

    def attributes
      # get attributes for this resource
      resource_attrs = KNOWN_RESOURCES.find { |r| r[:service] == service.to_sym and r[:name] == name.to_sym }
      # merge attributes for the resource's services
      service_attrs = KNOWN_SERVICES.find { |s| s[:service] == service.to_sym }
      return (resource_attrs || {}).merge(service_attrs || {})
    end

  end
end
