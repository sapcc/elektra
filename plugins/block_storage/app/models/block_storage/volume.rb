 # frozen_string_literal: true

module BlockStorage
  class Volume < Core::ServiceLayer::Model
    validates :name, :description, presence: true
    validates :size, presence: true, if: proc { |v| v.snapshot_id.blank? }
    validates :size, numericality: { only_integer: true, greater_than: 0 },
                     if: proc { |v| v.snapshot_id.blank? }
    validate :avalability_zone_or_snapshot_id

    def attributes_for_create
      {
        'name'              => read('name'),
        'description'       => read('description'),
        'size'              => read('size'),
        'availability_zone' => read('availability_zone'),
        'snapshot_id'       => read('snapshot_id'),
        'source_volid'      => read('source_volid'),
        'multiattach'       => read('multiattach'),
        'backup_id'         => read('backup_id'),
        'imageRef'          => read('imageRef'),
        'volume_type'       => read('volume_type'),
        'metadata'          => read('metadata'),
        'consistencygroup_id' => read('consistencygroup_id')
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

    def extend_size(size)
      rescue_api_errors do
        service.extend_volume_size(id, size)
        self.size = size
      end
    end

    def upload_to_image(image_options)
      rescue_api_errors do
        service.upload_volume_to_image(id, {
          'image_name' => image_options[:image_name],
          'force' => image_options[:force],
          'disk_format' => image_options[:disk_format],
          'container_format' => image_options[:container_format],
          'visibility' => image_options[:visibility],
          'protected' => image_options[:protected]
        })
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
