# frozen_string_literal: true

module Identity
  # This class represents the Openstack Domain
  class Domain < Core::ServiceLayer::Model
    def friendly_id
      return nil if id.nil?
      return id if name.blank?

      friendly_id_entry =
        FriendlyIdEntry.find_or_create_entry(
          "Domain",
          nil,
          id,
          attributes["name"],
        )
      friendly_id_entry.slug
    end
  end
end
