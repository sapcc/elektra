# frozen_string_literal: true

module Compute
  # Represents the Service
  class Service < Core::ServiceLayer::Model
    validates :reason,
              presence: {
                message: "Please give a reason",
              },
              on: :disable

    def disableable?
      valid? :disable
    end

    def name
      read("binary")
    end

    def enabled?
      status == "enabled"
    end

    def enable
      rescue_api_errors { service.enable_service(id, "nova-compute") }
    end

    def disable
      return false unless disableable?
      rescue_api_errors do
        if reason
          service.disable_service_reason(id, "nova-compute", reason)
        else
          service.disable_service(id, "nova-compute")
        end
      end
    end
  end
end
