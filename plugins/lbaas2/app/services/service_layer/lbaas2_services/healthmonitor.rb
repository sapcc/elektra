module ServiceLayer
  module Lbaas2Services
    module Healthmonitor

      def healthmonitor_map
        @healthmonitor_map ||= class_map_proc(::Lbaas2::Healthmonitor)
      end

      def healthmonitors(filter = {})
        elektron_lb2.get('healthmonitors', filter).map_to(
          'body.healthmonitors', &healthmonitor_map
        )
      end

      def find_healthmonitor!(id)
        elektron_lb2.get("healthmonitors/#{id}").map_to(
          'body.healthmonitor', &healthmonitor_map
        )
      end

    end
  end
end
