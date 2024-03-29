# frozen_string_literal: true

module ServiceLayer
  module NetworkingServices
    # Implements Openstack Router
    module Router
      def router_map
        @router_map ||= class_map_proc(Networking::Router)
      end

      def routers(filter = {})
        elektron_networking.get("routers", filter).map_to(
          "body.routers",
          &router_map
        )
      end

      def find_router!(id)
        return nil unless id
        elektron_networking.get("routers/#{id}").map_to(
          "body.router",
          &router_map
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
            "routers/#{router_id}/add_router_interface",
          ) { { subnet_id: interface_id } }
        end
      end

      def remove_router_interfaces(router_id, interface_ids)
        interface_ids.each do |interface_id|
          elektron_networking.put(
            "routers/#{router_id}/remove_router_interface",
          ) { { subnet_id: interface_id } }
        end
      end

      ################### Model Interface ###################
      def create_router(attributes)
        elektron_networking.post("routers") { { "router" => attributes } }.body[
          "router"
        ]
      end

      def update_router(id, attributes)
        elektron_networking
          .put("routers/#{id}") { { "router" => attributes } }
          .body[
          "router"
        ]
      rescue Elektron::Errors::ApiResponse => e
        # regarding the issue https://github.com/sapcc/elektra/issues/879
        # If the external network is outside of this scope (other owner project),
        # update of the router will throw the error "Port ... could not be found".
        # This has to do with the fact that the associated port also exists
        # outside of this scope and therefore cannot be found from this scope (current user).
        # We handle this case by catching the appropriate error and doing nothing.
        raise e if !(e.message =~ /Port .+ could not be found/i)
      end

      def delete_router(id)
        elektron_networking.delete("routers/#{id}")
      end
    end
  end
end
