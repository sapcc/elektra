# frozen_string_literal: true

module ServiceLayerNg
  class SharedFilesystemStorageService < Core::ServiceLayerNg::Service
    include SharedFilesystemStorageServices::Share

    def available?(_action_name_sym = nil)
      !current_user.service_url('sharev2', region: region).nil?
    end
  end
end
