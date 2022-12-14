# frozen_string_literal: true

module DnsService
  # This class represents the Openstack Designate Pool
  class SharedZone < Core::ServiceLayer::Model
    validates :target_project_id,
              presence: {
                message: "Please provide a valid openstack-id",
              }
  end
end
