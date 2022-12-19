# frozen_string_literal: true

module Identity
  # This class represents the Openstack Group
  class Group < Core::ServiceLayer::Model
    validates :name,
              presence: {
                message: "Please provide a name for this group.",
              }
  end
end
