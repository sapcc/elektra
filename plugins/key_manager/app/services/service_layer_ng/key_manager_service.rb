# frozen_string_literal: true

module ServiceLayerNg
  # key manager service layer
  class KeyManagerService < Core::ServiceLayerNg::Service
    include KeyManagerServices::Secret
    include KeyManagerServices::Container

    def available?(_action_name_sym = nil)
      elektron.service?('key-manager')
    end

    def elektron_key_manager
      @elektron_key_manager ||= elektron(debug: Rails.env.development?).service(
        'key-manager', path_prefix: '/v1'
      )
    end
  end
end
