# frozen_string_literal: true

module ServiceLayerNg
  module LoadbalancingServices
    # This module implements Openstack Designate Pool API
    module Pool

      def pools(filter={})
        driver.map_to(Loadbalancing::Pool).pools(filter)
      end

      def find_pool(pool_id)
        driver.map_to(Loadbalancing::Pool).get_pool(pool_id)
      end

      def new_pool(attributes={})
        Loadbalancing::Pool.new(driver, attributes)
      end

      def pool_members(filter={})
        driver.map_to(Loadbalancing::PoolMember).pool_members(filter)
      end

      def find_pool_member(pool_id, member_id)
        driver.map_to(Loadbalancing::PoolMember).get_pool_member(pool_id, member_id)
      end

      def delete_pool_member(pool_id, member_id)
        driver.map_to(Loadbalancing::PoolMember).delete_pool_member(pool_id, member_id)
      end

      def new_pool_member(attributes={})
        Loadbalancing::PoolMember.new(driver, attributes)
      end

      ################# INTERFACE METHODS ######################
      def create_pool(params)
        elektron_shares.post('security-services') do
          { security_service: params }
        end.body['security_service']
      end

      def update_pool(id, params)
        elektron_shares.put("security-services/#{id}") do
          { security_service: params }
        end.body['security_service']
      end

      def delete_pool(id)
        elektron_shares.delete("security-services/#{id}")
      end
    end
  end
end
