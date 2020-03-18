module ServiceLayer
  module Lbaas2Services
    module Listener

      def listener_map
        @listener_map ||= class_map_proc(::Lbaas2::Listener)
      end

      def listeners(filter = {})
        elektron_lb2.get('listeners', filter).map_to(
          'body.listeners', &listener_map
        )
      end

    end
  end
end