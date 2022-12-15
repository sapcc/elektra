# frozen_string_literal: true

module ServiceLayer
  # implements the LBAAS API
  class Lbaas2Service < Core::ServiceLayer::Service
    include Lbaas2Services::LoadbalancerV2
    include Lbaas2Services::ListenerV2
    include Lbaas2Services::PoolV2
    include Lbaas2Services::L7policyV2
    include Lbaas2Services::L7ruleV2
    include Lbaas2Services::HealthmonitorV2
    include Lbaas2Services::MemberV2
    include Lbaas2Services::AvailabilityZone

    def available?(_action_name_sym = nil)
      elektron.service?("octavia")
    end

    def elektron_lb2
      @elektron_lb2 ||= elektron.service("octavia", path_prefix: "/v2.0/lbaas")
    end

    def elektron_amphorae
      @elektron_lb2 ||=
        elektron.service("octavia", path_prefix: "/v2.0/octavia/amphorae")
    end
  end
end
