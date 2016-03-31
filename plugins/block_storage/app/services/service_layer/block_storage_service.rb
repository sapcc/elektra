module ServiceLayer

  class BlockStorageService < Core::ServiceLayer::Service

    def driver
      @driver ||= BlockStorage::Driver::BlockStorageDriver.new({
                                                                   auth_url: self.auth_url,
                                                                   region: self.region,
                                                                   token: self.token,
                                                                   domain_id: self.domain_id,
                                                                   project_id: self.project_id
                                                               })
    end

    def available?(action_name_sym=nil)
      true
    end


    def volumes filter={}
      driver.map_to(BlockStorage::Volume).volumes(filter)
    end

    def get_volume id
      return nil if id.blank?
      driver.map_to(BlockStorage::Volume).get_volume(id)
    end

    def new_volume(params={})
      BlockStorage::Volume.new(driver, params)
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

    def test
      driver.test
    end
  end
end