module BlockStorage
  class Volume < Core::ServiceLayer::Model
    validates :name, :description, :size, presence: true
    attr_accessor :assigned_server

    STATUS = [
      'creating',
      'available',
      'attaching',
      'detaching',
      'in-use',
      'maintenance',
      'deleting',
      'awaiting-transfer',
      'error',
      'error_deleting',
      'backing-up',
      'restoring-backup',
      'error_backing-up',
      'error_restoring',
      'error_extending',
      'downloading',
      'uploading',
      'retyping',
      'extending'
    ]

    ATTACH_STATUS = [
      'attached',
      'detached'
    ]

    MIGRATION_STATUS = [
      'migrating'
    ]


    def in_transition? target_state
      return false unless target_state
      Rails.logger.info { "Checking state transition for volume #{self.name} : target state: #{target_state} - actual state: #{self.status}" }
      if target_state.include? self.status
        return false
      else
        return true
      end
    end

    def deletable?
      return self.status != 'in-use'
    end

    def snapshotable?
      return self.status == 'available'
    end

    # { status: '...', attach_status: '...', migration_status: '...' }
    def reset_status(status={})
      begin
        @driver.volume_action(self.id,status)
        self.status = status[:status]
        return true
      rescue => e
        raise e unless defined?(@driver.handle_api_errors?) and @driver.handle_api_errors?

        Core::ServiceLayer::ApiErrorHandler.get_api_error_messages(e).each{|message| self.errors.add(:api, message)}
        return false
      end
    end

    def attached?
      status=='in-use'
    end

    def migrating?
      status=='maintenance'
    end

  end
end
