# frozen_string_literal: true

module ServiceLayer
  module LoadbalancingServices
    # This module implements Openstack Designate Pool API
    module L7policy
      def l7policy_map
        @l7policy_map ||= class_map_proc(::Loadbalancing::L7policy)
      end

      def l7policies(filter = {})
        elektron_lb.get('l7policies', filter).map_to(
          'body.l7policies', &l7policy_map
        )
      end

      def find_l7policy!(l7policy_id)
        elektron_lb.get("l7policies/#{l7policy_id}").map_to(
          'body.l7policy', &l7policy_map
        )
      end

      def find_l7policy(l7policy_id)
        find_l7policy!(l7policy_id)
      rescue Elektron::Errors::ApiResponse
        nil
      end

      def new_l7policy(attributes = {})
        l7policy_map.call(attributes)
      end

      ################# INTERFACE METHODS ######################
      def create_l7policy(params)
        elektron_lb.post('l7policies') do
          { l7policy: params }
        end.body['l7policy']
      end

      def update_l7policy(id, params)
        elektron_lb.put("l7policies/#{id}") do
          { l7policy: params }
        end.body['l7policy']
      end

      def delete_l7policy(id)
        elektron_lb.delete("l7policies/#{id}")
      end
    end
  end
end
