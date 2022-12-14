# frozen_string_literal: true

module ServiceLayer
  # key manager service layer
  class KeyManagerService < Core::ServiceLayer::Service
    include KeyManagerServices::Secret
    include KeyManagerServices::Container

    def available?(_action_name_sym = nil)
      elektron.service?("key-manager")
    end

    def elektron_key_manager
      @elektron_key_manager ||=
        elektron.service("key-manager", path_prefix: "/v1")
    end
  end
end
