module ResourceManagement
  class Resource < ActiveRecord::Base
    #validates [:service, :name], presence: true

    KNOWN_RESOURCES = [
      # TODO: incomplete
      { service: :block_storage,  name: :capacity  },
      { service: :block_storage,  name: :snapshots },
      { service: :block_storage,  name: :volumes   },
      { service: :object_storage, name: :capacity  },
    ]
  end
end
