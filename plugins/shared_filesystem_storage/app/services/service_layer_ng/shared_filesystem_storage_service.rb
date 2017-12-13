# frozen_string_literal: true

module ServiceLayerNg
  # implements manila api
  class SharedFilesystemStorageService < Core::ServiceLayerNg::Service
    include SharedFilesystemStorageServices::Share
    include SharedFilesystemStorageServices::ShareRule
    include SharedFilesystemStorageServices::ShareNetwork
    include SharedFilesystemStorageServices::SecurityService
    include SharedFilesystemStorageServices::Snapshot

    MICROVERSION = 2.15

    def available?(_action_name_sym = nil)
      !current_user.service_url('sharev2', region: region).nil?
    end

    def elektron_shares
      @elektron_shares ||= elektron.service(
        'sharev2',
        headers: { 'X-OpenStack-Manila-API-Version' => MICROVERSION.to_s }
      )
    end

    def class_map_proc(klass)
      proc { |params| klass.new(self, params) }
    end

    def microversion_newer_than?(version)
      version > MICROVERSION
    end
  end
end
