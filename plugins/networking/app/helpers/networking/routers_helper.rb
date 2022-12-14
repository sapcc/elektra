module Networking
  module RoutersHelper
    def foreign_router?(router)
      (router.tenant_id || router.project_id) != @scoped_project_id
    end

    def router_internal_subnets(router_id)
      ports =
        ObjectCache.where(
          [
            "payload ->> 'device_id' = ? AND payload ->> 'device_owner' = ?",
            router_id,
            "network:router_interface",
          ],
        ).where(cached_object_type: "port")
      subnet_ids =
        ports.each_with_object([]) do |port, array|
          (port.payload["fixed_ips"] || []).each do |ip|
            array << ip["subnet_id"]
          end
        end

      ObjectCache.where(id: subnet_ids)
    end

    def router_internal_networks(router)
      # ports = ObjectCache.where(
      #   ["payload ->> 'device_id' = ? AND payload ->> 'device_owner' = ?",
      #     router.id, 'network:router_interface'
      #   ]).where(cached_object_type: 'port')

      ports =
        cloud_admin.networking.ports(
          device_id: router.id,
          device_owner: "network:router_interface",
        ) #if ports.empty?

      network_ids =
        ports.collect do |port|
          if port.respond_to?(:payload)
            port.payload["network_id"]
          else
            port.network_id
          end
        end

      ObjectCache.where(id: network_ids)
    end
  end
end
