# frozen_string_literal: true

module EmailService
  # EmailService EmailVerificationsController
  class EmailVerificationsController < ::EmailService::ApplicationController
    # before_action :check_pre_conditions_for_cronus
    before_action :verified_email, only: %i[new create]

    authorization_context 'email_service'
    authorization_required

    def index
      items_per_page = 10
      @paginatable_emails =
        Kaminari
          .paginate_array(email_addresses, total_count: email_addresses.count)
          .page(params[:page])
          .per(items_per_page)
    rescue Elektron::Errors::ApiResponse, StandardError => e
      error =
        "#{I18n.t('email_service.errors.email_verification_list_error')} #{e.message}"
      Rails.logger.error error
      flash[:error] = error
    end

    def new
      @configsets_collection = list_configset_names
    end

    def create
      identity_values = @verified_email.process(EmailService::VerifiedEmail)
      msg = ''
      render :new and return unless @verified_email.valid?

      identities = process_email_verification(identity_values)
      identities.each { |id| msg += "#{id[:message]}; " }
      flash[:warning] = msg
      redirect_to plugin('email_service').email_verifications_path and return
    rescue Elektron::Errors::ApiResponse, StandardError => e
      error =
        "#{I18n.t('email_service.errors.email_verification_create_error')} #{e.message}"
      Rails.logger.error error
      flash[:error] = error
    end

    def destroy
      identity = params[:identity] unless params[:identity].nil?
      status = delete_email_identity(identity)
      flash[:success] = "The identity #{identity} is removed" if status ==
        'success'
      flash[
        :error
      ] = "The identity #{identity} removal failed : #{status}" unless status ==
        'success'
      redirect_to plugin('email_service').email_verifications_path and return
    rescue Elektron::Errors::ApiResponse, StandardError => e
      error =
        "#{I18n.t('email_service.errors.email_verification_delete_error')} #{e.message}"
      Rails.logger.error error
      flash[:error] = error
    end

    def process_email_verification(identity_values)
      identities = []
      if identity_values['identity'].length.positive?
        identity_values['identity'].each do |id|
          status = create_email_identity_email(id)
          unless status.nil?
            identities << {
              identity: id,
              status: status,
              message:
                "Verification email is sent to #{id}. Please click on the activation link.",
            }
          end
        end
      end
      identities
    end

    private

    def email_verification_params
      if params.include?(:verified_email)
        params.require(:verified_email).permit(
          :identity,
          :tags,
          :configuration_set_name
        )
      else
        {}
      end
    end

    def email_verification_form(attributes = {})
      EmailService::Forms::VerifiedEmail.new(attributes)
    end

    def verified_email
      @verified_email = email_verification_form(email_verification_params)
    end
  end
end
