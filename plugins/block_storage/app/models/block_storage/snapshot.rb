# frozen_string_literal: true

module BlockStorage
  class Snapshot < Core::ServiceLayer::Model
    validates :name, :description, presence: true

    STATUS = [
      # 'creating',
      'available',
      # 'deleting',
      'error',
      # 'error_deleting'
    ].freeze

    # { status: '...', attach_status: '...', migration_status: '...' }
    def reset_status(new_status)
      rescue_api_errors do
        service.reset_snapshot_status(id, status: new_status)
        self.status = new_status
      end
    end
  end
end
