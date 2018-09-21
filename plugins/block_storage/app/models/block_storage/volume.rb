 # frozen_string_literal: true

module BlockStorage
  class Volume < Core::ServiceLayer::Model
    validates :name, :description, :size, presence: true
    validates :size, numericality: { only_integer: true, greater_than: 0 }
    validate :avalability_zone_or_snapshot_id

    def attributes_for_create
      {
        'name'              => read('name'),
        'description'       => read('description'),
        'size'              => read('size'),
        'availability_zone' => read('availability_zone')
      }.delete_if { |_k, v| v.blank? }
    end

    def attributes_for_update
      {
        'name'              => read('name'),
        'description'       => read('description'),
        'metadata'          => read('metadata')
      }.delete_if { |_k, v| v.blank? }
    end

    def reset_status(status = {})
      rescue_api_errors do
        service.reset_volume_status(id, status)
        self.status = status[:status]
      end
    end

    def force_delete
      rescue_api_errors do
        service.force_delete_volume(id)
      end
    end

    def attach_to_server(server_id, device)
      rescue_api_errors do
        service.attach(id, server_id, device)
      end
    end

    def detach(attachment_id)
      rescue_api_errors do
        service.detach(id, attachment_id)
      end
    end

    def avalability_zone_or_snapshot_id
      if availability_zone.blank? && snapshot_id.blank?
        errors.add(:availability_zone, 'Please choose an availability zone')
      end
    end
  end
end
