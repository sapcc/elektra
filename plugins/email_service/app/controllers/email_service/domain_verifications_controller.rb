module EmailService
  class DomainVerificationsController < ::EmailService::ApplicationController

    before_action :check_ec2_creds_cronus_status
    before_action :check_verified_identity
    before_action :set_verified_domain, only: %i[new show]

    authorization_context 'email_service'
    authorization_required

    DOMIAN_VERIFICATION_INITIATED = "#{I18n.t('email_service.messages.domain_verification_initiated')}"
    
    def index

      items_per_page = 10
      @paginatable_domains = Kaminari.paginate_array(domains, total_count: domains.count).page(params[:page]).per(items_per_page)
      rescue Elektron::Errors::ApiResponse => e
        error = "#{I18n.t('email_service.errors.domain_verification_list_error')} #{e.message}"
        Rails.logger.debug error
        flash[:error] = error
      rescue Exception => e
        error = "#{I18n.t('email_service.errors.domain_verification_list_error')} #{e.message}"
        Rails.logger.debug error
        flash[:error] = error
    end

    def new

      @dkim_types = ::EmailService::VerifiedDomain.dkim_types
      @rsa_key_length = ::EmailService::VerifiedDomain.key_length
      @configsets_collection = configset_names
      
    end

    def create

      @dkim_types = ::EmailService::VerifiedDomain.dkim_types
      @rsa_key_length = ::EmailService::VerifiedDomain.key_length

      begin
        @verified_domain = domain_verification_form(domain_verification_params)
        tags = [{ key: "color", value: "red"}, { key: "type", value: "not_junk_mail"}]
        @verified_domain.tags = tags

        if @verified_domain.valid?
          msg = process_domain_verification(@verified_domain)
          if msg == "success"
            flash[:info] = DOMIAN_VERIFICATION_INITIATED
          end
          redirect_to plugin('email_service').domain_verifications_path and return
        else
          render :new and return
        end
        rescue Elektron::Errors::ApiResponse => e
          error = "#{I18n.t('email_service.errors.domain_verification_create_error')} #{e.message}"
          Rails.logger.error error
          flash[:error] = error
        rescue Exception => e
          error = "#{I18n.t('email_service.errors.domain_verification_create_error')} #{e.message}"
          Rails.logger.error error
          flash[:error] = error
        redirect_to plugin('email_service').domain_verifications_path
      end

    end

    def show
      begin
        @verified_identity = find_verified_identity_by_name(params[:identity_name], "DOMAIN")
      rescue Elektron::Errors::ApiResponse => e
        error = "#{I18n.t('email_service.errors.domain_verification_show_error')} #{e.message}"
        Rails.logger.error error
        flash[:error] = error
      rescue Exception => e
        error = "#{I18n.t('email_service.errors.domain_verification_show_error')} #{e.message}"
        Rails.logger.error error
        flash[:error] = error
      end
    end

    def destroy
      identity = params[:identity_name] unless params[:identity_name].nil?
      status = delete_email_identity(identity)
      if status == "success"
        msg = "The identity #{identity} is removed"
        flash[:success] = msg
        redirect_to plugin('email_service').domain_verifications_path and return
      else
        msg = "Identity #{identity} removal failed : #{status}"
        flash[:error] = msg
        redirect_to plugin('email_service').domain_verifications_path and return
      end

      rescue Elektron::Errors::ApiResponse => e
        error = "#{I18n.t('email_service.errors.domain_verification_delete_error')} #{e.message}"
        Rails.logger.error error
        flash[:error] = error
      rescue Exception => e
        error = "#{I18n.t('email_service.errors.domain_verification_delete_error')} #{e.message}"
        Rails.logger.error error
        flash[:error] = error
      redirect_to plugin('email_service').domain_verifications_path
    end

    def verify_dkim

      identity = params[:identity_name]
      status, resp = start_dkim_verification(domain)
      if status.include?("success")
        flash[:success] = "DKIM verification is initiated for [#{domain}]."
      else
        flash[:error] = "Unable to initiate DKIM verification for [#{domain}]. ERROR: #{status}"
        Rails.logger.error status
      end
      redirect_to plugin('email_service').domain_verifications_path

    end

    def activate_dkim
      identity = params[:identity_name]
      dkim_status, dkim_attributes = get_dkim_attributes([domain])
      @dkim_enabled = is_dkim_enabled(dkim_attributes, domain)
      Rails.logger.info  "@dkim_enabled : #{@dkim_enabled} "
      if @dkim_enabled == false
        st = toggle_dkim(identity, true)
      end
      flash[:success] = "DKIM for #{identity} is activated"
      redirect_to plugin('email_service').domain_verifications_path and return
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "#{I18n.t('email_service.errors.domain_verification_enable_dkim_error')} #{e.message}"
        Rails.logger.error  "#{I18n.t('email_service.errors.domain_verification_enable_dkim_error')} #{e.message}"
      rescue Exception => e
        flash[:error] = "#{I18n.t('email_service.errors.domain_verification_enable_dkim_error')} #{e.message}"
        Rails.logger.error "#{I18n.t('email_service.errors.domain_verification_enable_dkim_error')} #{e.message}"
    end

    def deactivate_dkim

      identity = params[:identity_name]
      begin
        sending_enabled, dkim_attributes = get_dkim_attributes(identity)
        if dkim_status
          toggle_dkim(identity, false)
        end
        flash[:success] = "DKIM for #{identity} is deactivated"

      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "#{I18n.t('email_service.errors.domain_verification_disable_dkim_error')} #{e.message}"
      rescue Exception => e
        flash[:error] = "#{I18n.t('email_service.errors.domain_verification_disable_dkim_error')} #{e.message}"
      end
      redirect_to plugin('email_service').domain_verifications_path and return
    end


    def process_domain_verification(verified_domain)
      status = nil
      status = create_email_identity_domain(verified_domain)
      return status

    end

    private

      def domain_verification_form(attributes={})
        verified_domain = EmailService::VerifiedDomain.new(attributes)
        return verified_domain
      end

      def set_verified_domain
        @verified_domain = find_identity_name(params[:identity_name])
      end

      def domain_verification_params
        if params.include?(:verified_domain)
          return params.require(:verified_domain).permit(:identity_name, :dkim_type, :tags, :domain_signing_private_key, :domain_signing_selector, :next_signing_key_length, :configuration_set_name)
        else
          {}
        end
      end

  end
end