module ServiceLayerNg

  class BlockStorageService < Core::ServiceLayerNg::Service
    include BlockStorageServices::Volume
    include BlockStorageServices::Snapshot

    def available?(_action_name_sym = nil)
      elektron.service?('volumev2')
    end

    def elektron_volumes
      @elektron_volumes ||= elektron(debug: Rails.env.development?).service(
        'volumev2'
      )
    end




    def snapshots filter={}
      driver.map_to(BlockStorage::Snapshot).snapshots(filter)
    end

    def get_snapshot id
      return nil if id.blank?
      driver.map_to(BlockStorage::Snapshot).get_snapshot(id)
    end

    def new_snapshot(params={})
      BlockStorage::Snapshot.new(driver, params)
    end
  end
end
