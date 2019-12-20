# frozen_string_literal: true

module ServiceLayer
  module LbaasServices
    # This module implements Openstack Designate Pool API
    module Listener
      def listener_map
        @listener_map ||= class_map_proc(::Lbaas::Listener)
      end

      def listeners(filter = {})
        elektron_lb.get('listeners', filter).map_to(
          'body.listeners', &listener_map
        )
      end

      def find_listener!(id)
        elektron_lb.get("listeners/#{id}").map_to(
          'body.listener', &listener_map
        )
      end

      def find_listener(id)
        find_listener!(id)
      rescue Elektron::Errors::ApiResponse
        nil
      end

      def new_listener(attributes = {})
        listener_map.call(attributes)
      end

      ################# INTERFACE METHODS ######################
      def create_listener(attributes)
        elektron_lb.post('listeners') do
          { listener: attributes }
        end.body['listener']
      end

      def update_listener(id, attributes)
        elektron_lb.put("listeners/#{id}") do
          { listener: attributes }
        end.body['listener']
      end

      def delete_listener(id)
        elektron_lb.delete("listeners/#{id}")
      end
    end
  end
end
