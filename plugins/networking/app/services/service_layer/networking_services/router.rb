# frozen_string_literal: true

module ServiceLayer
  module NetworkingServices
    # Implements Openstack Router
    module Router
      def router_map
        @router_map ||= class_map_proc(Networking::Router)
      end

      def routers(filter = {})
        elektron_networking.get('routers', filter).map_to(
          'body.routers', &router_map
        )
      end

      def find_router!(id)
        return nil unless id
        elektron_networking.get("routers/#{id}").map_to(
          'body.router', &router_map
        )
      end

      def find_router(id)
        find_router!(id)
      rescue Elektron::Errors::ApiResponse
        nil
      end

      def new_router(attributes = {})
        router_map.call(attributes)
      end

      def add_router_interfaces(router_id, interface_ids)
        interface_ids.each do |interface_id|
          elektron_networking.put(
            "routers/#{router_id}/add_router_interface"
          ) do
            { subnet_id: interface_id }
          end
        end
      end

      def remove_router_interfaces(router_id, interface_ids)
        interface_ids.each do |interface_id|
          elektron_networking.put(
            "routers/#{router_id}/remove_router_interface"
          ) do
            { subnet_id: interface_id }
          end
        end
      end

      ################### Model Interface ###################
      def create_router(attributes)
        elektron_networking.post('routers') do
          { 'router' => attributes }
        end.body['router']
      end

      def update_router(id, attributes)
        elektron_networking.put("routers/#{id}") do
          { 'router' => attributes }
        end.body['router']
      end

      def delete_router(id)
        elektron_networking.delete("routers/#{id}")
      end
    end
  end
end
