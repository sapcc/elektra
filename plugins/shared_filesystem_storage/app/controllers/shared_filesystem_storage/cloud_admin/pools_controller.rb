# frozen_string_literal: true

module SharedFilesystemStorage
  module CloudAdmin
    # This class implements the pools
    class PoolsController < ::DashboardController
      authorization_required context: '::shared_filesystem_storage', only: %i[index]

      def index
        @pools = services.shared_filesystem_storage.pools.uniq(&:aggregate)
      end

      def show
        @pool = services.shared_filesystem_storage.find_pool(params[:id])
      end
    end
  end
end
