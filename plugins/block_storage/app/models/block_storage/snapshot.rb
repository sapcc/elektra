# frozen_string_literal: true

module BlockStorage
  class Snapshot < Core::ServiceLayer::Model
    validates :name, :description, presence: true

    def attributes_for_create
      {
        'name'              => read('name'),
        'description'       => read('description'),
        'volume_id'         => read('volume_id'),
        'force'             => read('force'),
        'metadata'          => read('metadata')
      }.delete_if { |_k, v| v.blank? }
    end

    def attributes_for_update
      {
        'name'              => read('name'),
        'description'       => read('description')
      }.delete_if { |_k, v| v.blank? }
    end

    def reset_status(new_status)
      rescue_api_errors do
        service.reset_snapshot_status(id, status: new_status)
        self.status = new_status
      end
    end
  end
end
