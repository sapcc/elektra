# frozen_string_literal: true

module SharedFilesystemStorage
  # represents snapshot
  class Replica < Core::ServiceLayer::Model
    def resync
      rescue_api_errors { service.resync_replica(id) }
    end

    def promote
      rescue_api_errors { self.attributes = service.promote_replica(id) }
    end
  end
end
