# frozen_string_literal: true

module SharedFilesystemStorage
  # This class implements the share types
  class ShareTypesController < ApplicationController
    authorization_context "shared_filesystem_storage"
    authorization_required

    def index
      render json: services.shared_filesystem_storage.share_types
    end
  end
end
