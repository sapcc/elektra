# frozen_string_literal: true

module ServiceLayerNg
  module LoadbalancingServices
    # This module implements Openstack Designate Pool API
    module Healthmonitor

      def healthmonitors(filter={})
        driver.map_to(Loadbalancing::Healthmonitor).healthmonitors(filter)
      end

      def find_healthmonitor(healthmonitor_id)
        driver.map_to(Loadbalancing::Healthmonitor).get_healthmonitor(healthmonitor_id)
      end

      def new_healthmonitor(attributes={})
        Loadbalancing::Healthmonitor.new(driver, attributes)
      end

      ################# INTERFACE METHODS ######################
      def create_healthmonitor(params)
        elektron_shares.post('security-services') do
          { security_service: params }
        end.body['security_service']
      end

      def update_healthmonitor(id, params)
        elektron_shares.put("security-services/#{id}") do
          { security_service: params }
        end.body['security_service']
      end

      def delete_healthmonitor(id)
        elektron_shares.delete("security-services/#{id}")
      end
    end
  end
end
