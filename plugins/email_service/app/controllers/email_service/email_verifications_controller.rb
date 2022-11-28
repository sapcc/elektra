module EmailService
  class EmailVerificationsController < ::EmailService::ApplicationController

    before_action :check_ec2_creds_cronus_status
    before_action :verified_email, only: %i[new create]

    authorization_context 'email_service'
    authorization_required

    def index
      
      items_per_page = 10
      @paginatable_emails = Kaminari.paginate_array(email_addresses, total_count: email_addresses.count).page(params[:page]).per(items_per_page)
      rescue Elektron::Errors::ApiResponse => e
        error = "#{I18n.t('email_service.errors.email_verification_list_error')} #{e.message}"
        Rails.logger.error error
        flash[:error] = error
      rescue Exception => e
        error = "#{I18n.t('email_service.errors.email_verification_list_error')} #{e.message}"
        Rails.logger.error error
        flash[:error] = error
    end

    def new
      @configsets_collection = list_configset_names
    end


    def create

      identity_values = @verified_email.process(EmailService::VerifiedEmail)
      msg = ""
      if !@verified_email.valid?
        render :new and return
      else
        identities = process_email_verification(identity_values)
        identities.each do | id |
          msg+= "#{id[:message]}; "
        end
        flash[:warning] = msg
        redirect_to plugin('email_service').email_verifications_path and return
      end
      rescue Elektron::Errors::ApiResponse => e
        error = "#{I18n.t('email_service.errors.email_verification_create_error')} #{e.message}"
        Rails.logger.error error
        flash[:error] = error
      rescue Exception => e
        error = "#{I18n.t('email_service.errors.email_verification_create_error')} #{e.message}"
        Rails.logger.error error
        flash[:error] = error
        
    end

    def destroy
      
      identity = params[:identity] unless params[:identity].nil?
      status = delete_email_identity(identity)
      if status == "success"
        msg = "The identity #{identity} is removed"
        flash[:success] = msg
      else
        msg = "Identity #{identity} removal failed : #{status}"
        flash[:error] = msg
      end
      redirect_to plugin('email_service').email_verifications_path
      rescue Elektron::Errors::ApiResponse => e
        error = "#{I18n.t('email_service.errors.email_verification_delete_error')} #{e.message}"
        Rails.logger.error error
        flash[:error] = error
      rescue Exception => e
        error = "#{I18n.t('email_service.errors.email_verification_delete_error')} #{e.message}"
        Rails.logger.error error
        flash[:error] = error

    end


    def process_email_verification(identity_values)

      identities = []
      if identity_values['identity'].length.positive?
        identity_values['identity'].each do | id |
          Rails.logger.debug "\n ************** ID #{id} **************\n"
            status = create_email_identity_email(id)
            unless status.nil?
              identities << { identity: id, status: status, message: "Verification email is sent to #{id}. Please click on the activation link." }
            end
        end
      end
      return identities

    end

    private

      def email_verification_params
        if params.include?(:verified_email)
          return params.require(:verified_email).permit(:identity, :tags, :configset_name)
        else
          {}
        end
      end

      def email_verification_form(attributes={})
        EmailService::Forms::VerifiedEmail.new(attributes)
      end

      def verified_email
        @verified_email = email_verification_form(email_verification_params)
      end

  end
end
