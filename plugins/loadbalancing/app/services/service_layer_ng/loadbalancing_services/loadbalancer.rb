# frozen_string_literal: true

module ServiceLayerNg
  module LoadbalancingServices
    # This module implements Openstack Designate Pool API
    module Loadbalancer

      def loadbalancers(filter={})
        driver.map_to(Loadbalancing::Loadbalancer).loadbalancers(filter)
      end

      def find_loadbalancer(id)
        driver.map_to(Loadbalancing::Loadbalancer).get_loadbalancer(id)
      end

      def get_loadbalancer_hosting_agent(id)
        driver.map_to(Loadbalancing::Loadbalancer).get_loadbalancer_hosting_agent(id)
      end

      def new_loadbalancer(attributes={})
        Loadbalancing::Loadbalancer.new(driver, attributes)
      end

      def loadbalancer_statuses(id)
        driver.map_to(Loadbalancing::Statuses).get_loadbalancer_statuses(id)
      end

      def loadbalancer_changeable?(id, block_source)
        status = loadbalancer_statuses(id).find_state(id).provisioning_status rescue nil
        return false unless status
        count = 0
        until ['ACTIVE', 'ERROR'].include?(status)
          if count >= 6*2
            return false
          else
            count += 1
            Rails.logger.warn "Loadbalancer in state: #{status}. Waiting for action execution of #{block_source} for #{10*count} seconds in total."
            sleep 10
            status = loadbalancer_statuses(id).find_state(id).provisioning_status rescue nil
            return false unless status
          end
        end
        return true
      end

      def execute(id, &block)
        if loadbalancer_changeable?(id, block.source)
          return block.call
        else
          return false
        end
      end
      
      ################# INTERFACE METHODS ######################
      def create_loadbalancer(params)
        elektron_shares.post('security-services') do
          { security_service: params }
        end.body['security_service']
      end

      def update_loadbalancer(id, params)
        elektron_shares.put("security-services/#{id}") do
          { security_service: params }
        end.body['security_service']
      end

      def delete_loadbalancer(id)
        elektron_shares.delete("security-services/#{id}")
      end
    end
  end
end
