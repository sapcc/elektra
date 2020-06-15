module ServiceLayer
  module Lbaas2Services
    module HealthmonitorV2

      def healthmonitor_map
        @healthmonitor_map ||= class_map_proc(::Lbaas2::Healthmonitor)
      end

      def healthmonitors(filter = {})
        elektron_lb2.get('healthmonitors', filter).map_to(
          'body.healthmonitors', &healthmonitor_map
        )
      end

      def find_healthmonitor(id)
        elektron_lb2.get("healthmonitors/#{id}").map_to(
          'body.healthmonitor', &healthmonitor_map
        )
      end

      def new_healthmonitor(attributes = {})
        healthmonitor_map.call(attributes)
      end

      ################# INTERFACE METHODS ######################
      def create_healthmonitor(params)
        elektron_lb2.post('healthmonitors') do
          { healthmonitor: params }
        end.body['healthmonitor']
      end

      def update_healthmonitor(id, params)
        elektron_lb2.put("healthmonitors/#{id}") do
          { healthmonitor: params }
        end.body['healthmonitor']
      end

      def delete_healthmonitor(id)
        elektron_lb2.delete("healthmonitors/#{id}")
      end

    end
  end
end
