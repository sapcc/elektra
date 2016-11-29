module SharedFilesystemStorage
  class ShareNetwork < Core::ServiceLayer::Model
    def attributes_for_update
      {
        "name"              => read("name"),
        "description"       => read("description")
      }.delete_if { |k, v| v.blank? }
    end
  end
end