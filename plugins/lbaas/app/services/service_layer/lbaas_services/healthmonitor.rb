# frozen_string_literal: true

module ServiceLayer
  module LbaasServices
    # This module implements Openstack Designate Pool API
    module Healthmonitor
      def healthmonitor_map
        @healthmonitor_map ||= class_map_proc(::Lbaas::Healthmonitor)
      end

      def healthmonitors(filter = {})
        elektron_lb.get('healthmonitors', filter).map_to(
          'body.healthmonitors', &healthmonitor_map
        )
      end

      def find_healthmonitor!(id)
        elektron_lb.get("healthmonitors/#{id}").map_to(
          'body.healthmonitor', &healthmonitor_map
        )
      end

      def find_healthmonitor(id)
        find_healthmonitor!(id)
      rescue Elektron::Errors::ApiResponse
        nil
      end

      def new_healthmonitor(attributes = {})
        healthmonitor_map.call(attributes)
      end

      ################# INTERFACE METHODS ######################
      def create_healthmonitor(params)
        elektron_lb.post('healthmonitors') do
          { healthmonitor: params }
        end.body['healthmonitor']
      end

      def update_healthmonitor(id, params)
        elektron_lb.put("healthmonitors/#{id}") do
          { healthmonitor: params }
        end.body['healthmonitor']
      end

      def delete_healthmonitor(id)
        elektron_lb.delete("healthmonitors/#{id}")
      end
    end
  end
end
