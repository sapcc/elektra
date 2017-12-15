module BlockStorage
  class SnapshotNg  < Core::ServiceLayerNg::Model
    validates :name, :description, presence: true

    STATUS = [
      # 'creating',
      'available',
      # 'deleting',
      'error',
      # 'error_deleting'
    ]

    # { status: '...', attach_status: '...', migration_status: '...' }
    def reset_status(new_status)
      begin
        service.reset_snapshot_status(id, status: new_status)
        self.status = new_status
        return true
      rescue => e
        raise e unless defined?(@driver.handle_api_errors?) and @driver.handle_api_errors?

        Core::ServiceLayer::ApiErrorHandler.get_api_error_messages(e).each{|message| self.errors.add(:api, message)}
        return false
      end
    end
  end
end
