# frozen_string_literal: true

module SharedFilesystemStorage
  # represents share
  class Share < Core::ServiceLayer::Model
    def attributes_for_update
      {
        "display_name" => read("name"),
        "display_description" => read("description"),
      }.delete_if { |_k, v| v.blank? }
    end

    def update_size(new_size)
      requires :id
      new_size = new_size.to_i
      rescue_api_errors do
        if new_size < size.to_i
          service.shrink_share_size(id, new_size)
        elsif new_size > size.to_i
          service.extend_share_size(id, new_size)
        end
      end

      if errors.empty?
        self.attributes = service.find_share(id).attributes
        return true
      end
      false
    end

    def reset_state(new_state)
      rescue_api_errors do
        service.reset_share_state(id, new_state)
        self.status = new_state
      end
    end

    def force_delete
      rescue_api_errors { service.force_delete_share(id) }
    end

    def revert_to_snapshot(snapshot_id)
      rescue_api_errors { service.revert_share_to_snapshot(id, snapshot_id) }
    end
  end
end
