# frozen_string_literal: true

module ServiceLayerNg
  module NetworkingServices
    # Implements Openstack Router
    module Router
      def router_map
        @router_map ||= class_map_proc(Networking::Router)
      end

      def routers(filter = {})
        byebug
        elektron_networking.get('routers', filter).map_to(
          'body.routers', &router_map
        )
        # api.networking.list_routers(filter).map_to(Networking::Router)
      end

      def find_router!(id)
        byebug
        return nil unless id
        elektron_networking.get("routers/#{id}").map_to(
          'body.router', &router_map
        )
        # api.networking.show_router_details(id).map_to(Networking::Router)
      end

      def find_router(id)
        find_router!(id)
      rescue Elektron::Errors::ApiResponse
        nil
      end

      def new_router(attributes = {})
        byebug
        router_map.call(attributes)
        # map_to(Networking::Router, attributes)
      end

      def add_router_interfaces(router_id, interface_ids)
        byebug
        interface_ids.each do |interface_id|
          elektron_networking.put(
            "routers/#{router_id}/add_router_interface",
            subnet_id: interface_id
          )
          # api.networking.add_interface_to_router(
          #   router_id, subnet_id: interface_id
          # )
        end
      end

      def remove_router_interfaces(router_id, interface_ids)
        byebug
        interface_ids.each do |interface_id|
          elektron_networking.put(
            "routers/#{router_id}/remove_router_interface",
            subnet_id: interface_id
          )
          # api.networking.remove_interface_from_router(
          #   router_id, subnet_id: interface_id
          # )
        end
      end

      ################### Model Interface ###################
      def create_router(attributes)
        byebug
        elektron_networking.post('routers') do
          { 'router' => attributes }
        end.body['router']
        # api.networking.create_router(router: attributes).data
      end

      def update_router(id, attributes)
        byebug
        elektron_networking.put('routers') do
          { 'router' => attributes }
        end.body['router']
        # api.networking.update_router(id, router: attributes).data
      end

      def delete_router(id)
        byebug
        elektron_networking.delete("routers/#{id}")
        # api.networking.delete_router(id)
      end
    end
  end
end
