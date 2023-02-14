module Image
  class Member < Core::ServiceLayer::Model
    validates :image_id, presence: { message: "Could not find image" }
    validates :member,
              presence: {
                message: "Could not find project",
              },
              if: :new?

    def attributes_for_create
      {
        "member" => read("member"),
        "image_id" => read("image_id"),
      }.delete_if { |_, v| v.blank? }
    end

    def attributes_for_update
      {
        "image_id" => read("image_id"),
        "member_id" => read("member_id"),
        "status" => read("status"),
      }.delete_if { |_, v| v.blank? }
    end

    def id
      member_id
    end

    def perform_service_create(create_attributes)
      service.add_member_to_image(
        create_attributes["image_id"],
        create_attributes["member"],
      ).attributes
    end

    def perform_service_delete(id)
      service.remove_member_from_image(image_id, id)
    end

    def accept
      rescue_api_errors do
        self.attributes = service.accept_member(self).attributes
      end
    end

    def reject
      rescue_api_errors do
        self.attributes = service.reject_member(self).attributes
      end
    end

    protected

    def new?
      id.nil?
    end
  end
end
