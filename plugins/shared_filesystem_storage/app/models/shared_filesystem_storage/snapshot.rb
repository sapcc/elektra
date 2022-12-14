# frozen_string_literal: true

module SharedFilesystemStorage
  # represents snapshot
  class Snapshot < Core::ServiceLayer::Model
    def attributes_for_update
      {
        "display_name" => read("name"),
        "display_description" => read("description"),
      }.delete_if { |_k, v| v.blank? }
    end
  end
end
