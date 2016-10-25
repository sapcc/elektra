module ServiceLayer

  class SharedFilesystemStorageService < Core::ServiceLayer::Service

    def driver
      @driver ||= SharedFilesystemStorage::Driver::Fog.new({
        auth_url:   self.auth_url,
        region:     self.region,
        token:      self.token,
        domain_id:  self.domain_id,
        project_id: self.project_id  
      })
    end
    
    def available?(action_name_sym=nil)
      true  
    end
    
    ####################################################
    #                 SHARES                           #
    ####################################################
    def shares(filter = {})
			driver.map_to(SharedFilesystemStorage::Share).list_shares(filter) 
		end

    def shares_detail(filter={})
      driver.map_to(SharedFilesystemStorage::Share).list_shares_detail(filter) 
		end

    def find_share(id)
      driver.map_to(SharedFilesystemStorage::Share).get_share(id) 
		end
    
    def new_share(params={})
      SharedFilesystemStorage::Share.new(driver,params)
    end
    
    def share_rules(share_id)
      driver.map_to(SharedFilesystemStorage::ShareRule).list_share_access_rules(share_id)
    end
    
    def new_share_rule(share_id, params={})
      SharedFilesystemStorage::ShareRule.new(driver,params.merge(share_id: share_id))
    end
    
    ####################################################
    #                 SNAPSHOTS                        #
    ####################################################
    def snapshots(filter = {})
			driver.map_to(SharedFilesystemStorage::Snapshot).list_snapshots(filter) 
		end
    
    def snapshots_detail(filter = {})
			driver.map_to(SharedFilesystemStorage::Snapshot).list_snapshots_detail(filter) 
		end

    def find_snapshot(id)
      driver.map_to(SharedFilesystemStorage::Snapshot).get_snapshot(id) 
		end
    
    def new_snapshot(params={})
      SharedFilesystemStorage::Snapshot.new(driver,params)
    end
    
    
    ####################################################
    #                 SHARED NETWORKS                  #
    ####################################################
    def share_networks(filter = {})
			driver.map_to(SharedFilesystemStorage::ShareNetwork).list_share_networks(filter) 
		end

    def new_share_network(params={})
      SharedFilesystemStorage::ShareNetwork.new(driver,params)
    end
    
    def share_networks_detail(filter = {})
			driver.map_to(SharedFilesystemStorage::ShareNetwork).list_share_networks_detail(filter) 
		end

    def find_share_network(id)
      driver.map_to(SharedFilesystemStorage::ShareNetwork).get_share_network(id) 
		end
    
    def delete_share_network(id)
      driver.delete_share_network(id)
    end
  end
end