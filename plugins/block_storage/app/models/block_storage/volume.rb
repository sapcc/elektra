module BlockStorage
  class Volume < Core::ServiceLayer::Model
    validates :name, :description, :size, presence: true
    validates :size, numericality: { only_integer: true, greater_than: 0 }
    validate :avalability_zone_or_snapshot_id
    attr_accessor :assigned_server

    STATUS = [
        # 'creating',
        'available',
        # 'attaching',
        # 'detaching',
        # 'in-use',
        # 'maintenance',
        # 'deleting',
        # 'awaiting-transfer',
        'error',
        # 'error_deleting',
        # 'backing-up',
        # 'restoring-backup',
        # 'error_backing-up',
        # 'error_restoring',
        # 'error_extending',
        # 'downloading',
        # 'uploading',
        # 'retyping',
        # 'extending'
    ].freeze

    ATTACH_STATUS = %w(
      attached
      detached
    ).freeze

    def in_transition? target_state
      return false unless target_state
      Rails.logger.info {"Checking state transition for volume #{self.name} : target state: #{target_state} - actual state: #{self.status}"}
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
    def reset_status(status = {})
      @driver.reset_status(id, status)
      self.status = status[:status]
      return true
    rescue => e
      raise e unless defined?(@driver.handle_api_errors?) and @driver.handle_api_errors?

      Core::ServiceLayer::ApiErrorHandler.get_api_error_messages(e).each {|message| self.errors.add(:api, message)}
      return false
    end

    def force_delete
      begin
        @driver.force_delete(self.id)
        return true
      rescue => e
        raise e unless defined?(@driver.handle_api_errors?) and @driver.handle_api_errors?

        Core::ServiceLayer::ApiErrorHandler.get_api_error_messages(e).each {|message| self.errors.add(:api, message)}
        return false
      end
    end

    def attached?
      status=='in-use'
    end

    def migrating?
      status=='maintenance'
    end

    def avalability_zone_or_snapshot_id
      if self.availability_zone.blank? && self.snapshot_id.blank?
        errors.add(:availability_zone, 'Please choose an availability zone')
      end
    end

  end
end
