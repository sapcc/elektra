# frozen_string_literal: true

module ServiceLayerNg
  class SharedFilesystemStorageService < Core::ServiceLayerNg::Service
    include SharedFilesystemStorageServices::Share
    include SharedFilesystemStorageServices::ShareRule

    def available?(_action_name_sym = nil)
      !current_user.service_url('sharev2', region: region).nil?
    end

    def elektron_service
      @elektron_service ||= elektron(debug: true).service(
        'sharev2',
        headers: { 'X-OpenStack-Manila-API-Version' => '2.15' }
      )
    end
  end
end
