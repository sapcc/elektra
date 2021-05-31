# frozen_string_literal: true

module SharedFilesystemStorage
  # represents snapshot
  class Replica < Core::ServiceLayer::Model

    def resync
      rescue_api_errors do
        service.resync_replica(id)
      end
    end

    def promote
      rescue_api_errors do
        self.attributes = service.promote_replica(id)
      end
    end

  end
end
