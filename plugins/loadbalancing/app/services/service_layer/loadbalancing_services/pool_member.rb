# frozen_string_literal: true

module ServiceLayer
  module LoadbalancingServices
    # This module implements Openstack Designate Pool API
    module PoolMember
      def pool_member_map
        @pool_member_map ||= class_map_proc(::Loadbalancing::PoolMember)
      end

      def pool_members(id, filter = {})
        elektron_lb.get("pools/#{id}/members", filter).map_to(
          'body.members', &pool_member_map
        )
      end

      def find_pool_member!(pool_id, member_id)
        elektron_lb.get("pools/#{pool_id}/members/#{member_id}").map_to(
          'body.member', &pool_member_map
        )
      end

      def find_pool_member(pool_id, member_id)
        find_pool_member!(pool_id, member_id)
      rescue Elektron::Errors::ApiResponse
        nil
      end

      def new_pool_member(attributes = {})
        pool_member_map.call(attributes)
      end

      ################# INTERFACE METHODS ######################
      def create_pool_member(pool_id, params)
        elektron_lb.post("pools/#{pool_id}/members") do
          { member: params }
        end.body['member']
      end

      def update_pool_member(pool_id, member_id, params)
        elektron_lb.put("pools/#{pool_id}/members/#{member_id}") do
          { member: params }
        end.body['member']
      end

      def delete_pool_member(pool_id, member_id)
        elektron_lb.delete("pools/#{pool_id}/members/#{member_id}")
      end
    end
  end
end
