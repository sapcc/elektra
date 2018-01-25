 # frozen_string_literal: true

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

    def attributes_for_update
      {
        'name'              => read('name'),
        'description'       => read('description'),
        'metadata'          => read('metadata')
      }.delete_if { |_k, v| v.blank? }
    end

    def in_transition? target_state
      return false unless target_state
      Rails.logger.info { "Checking state transition for volume #{self.name} : target state: #{target_state} - actual state: #{self.status}" }
      return false if target_state.include?(status)
      true
    end

    def deletable?
      status != 'in-use'
    end

    def snapshotable?
      status == 'available'
    end

    def attached?
      status == 'in-use'
    end

    def migrating?
      status == 'maintenance'
    end

    # { status: '...', attach_status: '...', migration_status: '...' }
    def reset_status(status = {})
      rescue_api_errors do
        service.reset_volume_status(id, status)
        self.status = status[:status]
      end
    end

    def force_delete
      rescue_api_errors do
        service.delete_volume(id)
      end
    end

    def avalability_zone_or_snapshot_id
      if availability_zone.blank? && snapshot_id.blank?
        errors.add(:availability_zone, 'Please choose an availability zone')
      end
    end
  end
end
