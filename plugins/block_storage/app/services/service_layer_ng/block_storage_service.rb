# frozen_string_literal: true

module ServiceLayerNg
  class BlockStorageService < Core::ServiceLayerNg::Service
    include BlockStorageServices::Volume
    include BlockStorageServices::Snapshot

    def available?(_action_name_sym = nil)
      elektron.service?('volumev2')
    end

    def elektron_volumes
      @elektron_volumes ||= elektron.service(
        'volumev2'
      )
    end
  end
end
