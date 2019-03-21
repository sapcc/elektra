# frozen_string_literal: true

module SharedFilesystemStorage
  module CloudAdmin
    # This class implements the pools
    class PoolsController < ::DashboardController
      authorization_required context: '::shared_filesystem_storage', only: %i[index]

      def index
        # load services and build a map of host => availability_zone
        host_az_map = services.shared_filesystem_storage.services(
          binary: 'manila-share'
        ).each_with_object({}) do |service,map|
          host = service.host.gsub(/@.+/,'')
          map[host] = service.zone
        end

        productive_pools = services.shared_filesystem_storage.pools(
          share_type: 'default'
        )
        # load pools and add availability_zone to each pool based on host using
        # the host_az_map.
        @pools = productive_pools.map do |pool|
          if pool.host && !pool.host.blank?
            pool.availability_zone = host_az_map[pool.host]
          end
          pool.availability_zone ||= 'unknown'
          pool
        end.sort_by!(&:availability_zone)
      end

      def show
        @pool = services.shared_filesystem_storage.find_pool(params[:id])
      end
    end
  end
end
