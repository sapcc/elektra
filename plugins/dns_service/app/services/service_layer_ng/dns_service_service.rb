# frozen_string_literal: true

module ServiceLayerNg
  class DnsServiceService < Core::ServiceLayerNg::Service
    include DnsServiceServices::Pool

    def available?(_action_name_sym = nil)
      !current_user.service_url('dns', region: region).nil?
    end
  end
end
