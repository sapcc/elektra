# frozen_string_literal: true

module EmailService
  # SettingsController
  class SettingsController < ::EmailService::ApplicationController
    before_action :check_pre_conditions_for_cronus

    authorization_context 'email_service'
    authorization_required

    def index
      @nebula_details = nebula_details
      @nebula_status = nebula_status
      @nebula_endpoint = nebula_endpoint_url
      @aws_account_details = aws_account_details
      @deliverability_dashboard_options = get_deliverability_dashboard_options
    rescue Elektron::Errors::ApiResponse, StandardError => e
      error =
        "#{I18n.t('email_service.errors.cronus_account_details_list')} : #{e.message}"
      Rails.logger.error error
      flash[:error] = error
    end
  end
end
