module ResourceManagement
  class Resource < ActiveRecord::Base
    #validates [:service, :name], presence: true

    KNOWN_RESOURCES = [
      { service: :block_storage,  name: :capacity  },
      { service: :block_storage,  name: :snapshots },
      { service: :block_storage,  name: :volumes   },
      { service: :object_storage, name: :capacity  },
      { service: :compute, name: :cores  },
      { service: :compute, name: :instances  },
      { service: :compute, name: :ram  },
      { service: :network, name: :networks  },
      { service: :network, name: :routers  },
      { service: :network, name: :ports  },
      { service: :network, name: :floating_ips  },
      { service: :network, name: :security_groups  },
      { service: :network, name: :subnets  },
    ]
  end
end
