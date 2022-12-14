# frozen_string_literal: true

module SharedFilesystemStorage
  module CloudAdmin
    # This class implements the pools
    class PoolsController < ::DashboardController
      authorization_required context: "::shared_filesystem_storage",
                             only: %i[index]

      def index
        # load services and build a map of host => availability_zone
        host_az_map =
          services
            .shared_filesystem_storage
            .services(binary: "manila-share")
            .each_with_object({}) do |service, map|
              host = service.host.gsub(/@.+/, "")
              map[host] = service.zone
            end

        productive_pools = []
        pool_names = []
        # cast boolean to integer to have default type at the top
        types =
          services.shared_filesystem_storage.all_share_types.sort_by do |type|
            type.is_default ? 0 : 1
          end

        types.each do |type|
          type_pools =
            services.shared_filesystem_storage.pools(share_type: type.id)
          type_pools.each do |type_pool|
            type_pool.type = type.name
            # report every pool only once
            unless pool_names.include?(type_pool.name)
              productive_pools << type_pool
              pool_names << type_pool.name
            end
          end
        end

        # load pools and add availability_zone to each pool based on host using
        # the host_az_map.
        @pools =
          productive_pools
            .map do |pool|
              if pool.host && !pool.host.blank?
                pool.availability_zone = host_az_map[pool.host]
              end
              pool.availability_zone ||= "unknown"
              pool
            end
            .sort_by! { |p| [p.availability_zone, p.type, p.host, p.aggregate] }
      end

      def show
        @pool = services.shared_filesystem_storage.find_pool(params[:id])
      end
    end
  end
end
