# frozen_string_literal: true

module EmailService
  # MulticloudAccountsController
  class MulticloudAccountsController < ::EmailService::ApplicationController

    before_action :set_multicloud_account, only: %i[new destroy]

    authorization_context 'email_service'
    authorization_required

    MULTICLOUD_ACCOUNT_CREATED =
      I18n.t('email_service.messages.multicloud_accoount_created').to_s.freeze
    MULTICLOUD_ACCOUNT_DELETED =
      I18n.t('email_service.messages.multicloud_accoount_removed').to_s.freeze

    def index
      @nebula_status = nebula_status
    end

    def new
    end

    def create
      @multicloud_account = multicloud_account_form(multicloud_account_params)
      multicloud_account_values =
        @multicloud_account.process(EmailService::MulticloudAccount)
      unless @multicloud_account.valid?
        render 'edit', locals: { data: { modal: true } } and return
      end
      status =
        nebula_activate(multicloud_account_values) if @multicloud_account.valid?
      unless status == 'success'
        flash.now[:error] = status
        render 'edit', locals: { data: { modal: true } } and return
      end
      flash[:success] = MULTICLOUD_ACCOUNT_CREATED
      redirect_to plugin('email_service').emails_path
    rescue Elektron::Errors::ApiResponse, StandardError => e
      error =
        "#{I18n.t('email_service.errors.multicloud_account_create')} #{e.message}"
      Rails.logger.error error
      flash[:error] = error
    end

    def destroy
      @multicloud_account.provider = 'aws'
      status = nebula_deactivate
      if status == 'success'
        flash[:success] = MULTICLOUD_ACCOUNT_DELETED
      else
        error =
          "#{I18n.t('email_service.errors.multicloud_account_delete')} #{e.message}"
        Rails.logger.error error
        flash[:error] = error
      end
      redirect_to plugin('email_service').settings_url
    end

    private

    def multicloud_account_form(attributes = {})
      EmailService::Forms::MulticloudAccount.new(attributes)
    end

    def set_multicloud_account
      @multicloud_account = multicloud_account_form(multicloud_account_params)
    end

    def multicloud_account_params
      if params.include?(:multicloud_account)
        params.require(:multicloud_account).permit(
          :account_env,
          :identity,
          :mail_type,
          :provider,
          :security_officer,
          :endpoint_url
        )
      else
        {}
      end
    end

  end
end
