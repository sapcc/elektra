# frozen_string_literal: true

module ServiceLayerNg
  class DnsServiceService < Core::ServiceLayerNg::Service
    include DnsServiceServices::Pool

    def available?(_action_name_sym = nil)
      elektron.service?('dns')
    end

    def elektron_dns
      @elektron_dns ||= elektron(debug: Rails.env.development?).service(
        'dns', path_prefix: '/v2'
      )
    end
  end
end
