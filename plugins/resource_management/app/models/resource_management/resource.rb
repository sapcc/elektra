module ResourceManagement
  class Resource < ActiveRecord::Base
    #validates [:service, :name], presence: true

    KNOWN_RESOURCES = [
      # "name" identifies the resource within its service.
      # "service" identifies the service from which we pull this resource.
      # "area" identifies the tab in which to display resources for this service.
      { area: :compute, service: :compute,        name: :cores           },
      { area: :compute, service: :compute,        name: :instances       },
      { area: :compute, service: :compute,        name: :ram             },
      { area: :network, service: :network,        name: :floating_ips    },
      { area: :network, service: :network,        name: :networks        },
      { area: :network, service: :network,        name: :ports           },
      { area: :network, service: :network,        name: :routers         },
      { area: :network, service: :network,        name: :security_groups },
      { area: :network, service: :network,        name: :subnets         },
      { area: :storage, service: :block_storage,  name: :capacity,       display_unit: 1 << 30 }, # stored in bytes, displayed in GiB
      { area: :storage, service: :block_storage,  name: :snapshots       },
      { area: :storage, service: :block_storage,  name: :volumes         },
      { area: :storage, service: :object_storage, name: :capacity,       display_unit: 1 << 30 }, # stored in bytes, displayed in GiB
    ]

    def attributes
      KNOWN_RESOURCES.each do |resource|
        return resource if resource[:service] == service.to_sym and resource[:name] == name.to_sym            
      end
      return {}
    end

  end
end
