# frozen_string_literal: true

module SharedFilesystemStorage
  # shares
  class ErrorMessagesController < ApplicationController
    def index
      per_page = (params[:per_page] || 20).to_i
      current_page = (params[:page] || 1).to_i

      error_messages = services.shared_filesystem_storage.error_messages(
        resource_id: params[:resource_id],
        sort_key: :created_at,
        sort_dir: :desc,
        limit: per_page + 1,
        offset: (current_page - 1) * per_page
      )

      render json: {
        error_messages: error_messages[0..per_page - 1],
        has_next: error_messages.length > per_page
      }
    end
  end
end
