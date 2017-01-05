module SharedFilesystemStorage
  module Driver
    # Compute calls
    class Fog < Core::ServiceLayer::Driver::Base
      include Core::ServiceLayer::FogDriver::ClientHelper

      def initialize(params)
        super(params)
        @fog = ::Fog::SharedFileSystem::OpenStack.new(auth_params)
      end

      # shares
      def list_shares(filter = {})
				handle_response { @fog.list_shares(filter).body['shares'] }
			end

      def list_shares_detail(filter={})
				handle_response { @fog.list_shares_detail(filter).body['shares'] }
			end

      def get_share(id)
				handle_response { @fog.get_share(id).body['share'] }
			end

      def create_share(protocol, size, options = {})
				handle_response { @fog.create_share(protocol, size, options).body['share'] }
			end

      def delete_share(id)
				handle_response { @fog.delete_share(id) }
			end

      def update_share(id, options = {})
				handle_response { @fog.update_share(id, options).body['share'] }
			end

      def manage_share
				raise 'Not implemented yet!'
        #handle_response { @fog.manage_share() }
			end

      def unmanage_share
				raise 'Not implemented yet!'
        #handle_response { @fog.unmanage_share() }
			end

      def shrink_share
				raise 'Not implemented yet!'
        #handle_response { @fog.shrink_share() }
			end

      def extend_share
				raise 'Not implemented yet!'
        #handle_response { @fog.extend_share() }
			end

      def grant_share_access(share_id,params={})
        handle_response {
          @fog.grant_share_access(share_id, params["access_to"], params["access_type"], params["access_level"]).body['access']
        }
			end

      def revoke_share_access(share_id,access_id)
        handle_response { @fog.revoke_share_access(share_id, access_id)}
			end

      def reset_share_state
				raise 'Not implemented yet!'
        #handle_response { @fog.reset_share_state() }
			end

      def list_share_access_rules(share_id)
        handle_response { @fog.list_share_access_rules(share_id).body['access_list'] }
			end

      def list_share_export_locations(share_id)
        handle_response { @fog.list_share_export_locations(share_id).body['export_locations']}
      end

      def force_share_delete
				raise 'Not implemented yet!'
        #handle_response { @fog.force_share_delete() }
			end

      def list_availability_zones
        handle_response{ @fog.list_availability_zones.body['availability_zones']}
      end

      # snapshots
      def list_snapshots(filter={})
        handle_response { @fog.list_snapshots(filter).body['snapshots'] }
			end

      def list_snapshots_detail(filter={})
        handle_response { @fog.list_snapshots_detail(filter).body['snapshots'] }
			end

      def get_snapshot(id)
        handle_response { @fog.get_snapshot(id).body['snapshot'] }
			end

      def create_snapshot(share_id,params)
        handle_response { @fog.create_snapshot(share_id,params).body['snapshot'] }
			end

      def delete_snapshot(id)
        handle_response { @fog.delete_snapshot(id).body['snapshot'] }
			end

      def update_snapshot(id, params)
        handle_response { @fog.update_snapshot(id, params).body['snapshot'] }
			end

      def manage_snapshot
				raise 'Not implemented yet!'
        #handle_response { @fog.manage_snapshot() }
			end

      def unmanage_snapshot
				raise 'Not implemented yet!'
        #handle_response { @fog.unmanage_snapshot() }
			end

      def reset_snapshot_state
				raise 'Not implemented yet!'
        #handle_response { @fog.reset_snapshot_state() }
			end

      def force_snapshot_delete
				raise 'Not implemented yet!'
        #handle_response { @fog.force_snapshot_delete() }
			end


      # shre networks
      def list_share_networks(filter={})
        handle_response { @fog.list_share_networks(filter).body['share_networks'] }
			end

      def list_share_networks_detail(filter={})
        handle_response { @fog.list_share_networks_detail(filter).body['share_networks'] }
			end

      def get_share_network(id)
        handle_response { @fog.get_share_network(id).body['share_network'] }
			end

      def create_share_network(params={})
        handle_response { @fog.create_share_network(params).body['share_network'] }
			end

      def delete_share_network(id)
        handle_response { @fog.delete_share_network(id).body['share_network'] }
			end

      def update_share_network(id,params)
        handle_response { @fog.update_share_network(id,params).body['share_network'] }
			end

      def add_security_group_to_share_network
				raise 'Not implemented yet!'
        #handle_response { @fog.add_security_group_to_share_network() }
			end

      def remove_security_group_from_share_network
				raise 'Not implemented yet!'
        #handle_response { @fog.remove_security_group_from_share_network() }
			end


      # security service
      def list_security_services
				raise 'Not implemented yet!'
        #handle_response { @fog.list_security_services() }
			end

      def list_security_services_detail
				raise 'Not implemented yet!'
        #handle_response { @fog.list_security_services_detail() }
			end

      def get_security_service
				raise 'Not implemented yet!'
        #handle_response { @fog.get_security_service() }
			end

      def create_security_service
				raise 'Not implemented yet!'
        #handle_response { @fog.create_security_service() }
			end

      def delete_security_service
				raise 'Not implemented yet!'
        #handle_response { @fog.delete_security_service() }
			end

      def update_security_service
				raise 'Not implemented yet!'
        #handle_response { @fog.update_security_service() }
			end


    end
  end
end
