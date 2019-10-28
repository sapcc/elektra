# frozen_string_literal: true

module ServiceLayer
  module LbaasServices
    # This module implements Openstack Designate Pool API
    module Loadbalancer
      def loadbalancer_map
        @loadbalancer_map ||= class_map_proc(::Lbaas::Loadbalancer)
      end

      def lb_status_map
        @lb_status_map ||= class_map_proc(::Lbaas::Statuses)
      end

      def loadbalancers(filter = {})
        elektron_lb.get('loadbalancers', filter).map_to(
          'body.loadbalancers', &loadbalancer_map
        )
      end

      def find_loadbalancer!(id)
        elektron_lb.get("loadbalancers/#{id}").map_to(
          'body.loadbalancer', &loadbalancer_map
        )
      end

      def find_loadbalancer(id)
        find_loadbalancer!(id)
      rescue Elektron::Errors::ApiResponse
        nil
      end

      def get_loadbalancer_hosting_agent!(id)
        elektron_lb.get("loadbalancers/#{id}/loadbalancer-hosting-agent")
                   .map_to('body.agent', &loadbalancer_map)
      end

      def get_loadbalancer_hosting_agent(id)
        get_loadbalancer_hosting_agent!(id)
      rescue Elektron::Errors::ApiResponse
        nil
      end

      def new_loadbalancer(attributes = {})
        loadbalancer_map.call(attributes)
      end

      def loadbalancer_statuses!(id)
        elektron_lb.get("loadbalancers/#{id}/statuses").map_to(
          'body.statuses', &lb_status_map
        )
      end

      def loadbalancer_statuses(id)
        loadbalancer_statuses!(id)
      rescue Elektron::Errors::ApiResponse
        nil
      end

      def loadbalancer_changeable?(id, block_source)
        status = loadbalancer_statuses(id).find_state(id).provisioning_status rescue nil
        return false unless status
        count = 0
        until ['ACTIVE', 'ERROR'].include?(status)
          return false if count >= (6*2)

          count += 1
          Rails.logger.warn "Loadbalancer in state: #{status}. Waiting for action execution of #{block_source} for #{10*count} seconds in total."
          sleep 10
          status = loadbalancer_statuses(id).find_state(id).provisioning_status rescue nil
          return false unless status
        end
        true
      end

      def execute(id, &block)
        return yield if loadbalancer_changeable?(id, block.source)
        false
      end

      ################# INTERFACE METHODS ######################
      def create_loadbalancer(attributes)
        elektron_lb.post('loadbalancers') do
          { loadbalancer: attributes }
        end.body['loadbalancer']
      end

      def update_loadbalancer(id, attributes)
        elektron_lb.put("loadbalancers/#{id}") do
          { loadbalancer: attributes }
        end.body['loadbalancer']
      end

      def delete_loadbalancer(id)
        elektron_lb.delete("loadbalancers/#{id}")
      end
    end
  end
end
