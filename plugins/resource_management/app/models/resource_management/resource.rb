module ResourceManagement
  class Resource < ActiveRecord::Base
    #validates [:service, :name], presence: true

    KNOWN_RESOURCES = [
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

    def self.get_known_resource(service, name)
      KNOWN_RESOURCES.each do |resource|
        return resource if resource[:service] == service.to_sym and resource[:name] == name.to_sym            
      end
      false
    end

  end
end
