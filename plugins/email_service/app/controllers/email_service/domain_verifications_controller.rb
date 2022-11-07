module EmailService
  class DomainVerificationsController < ::EmailService::ApplicationController

    before_action :check_ec2_creds_cronus_status
    before_action :check_verified_identity
    before_action :set_verified_domain, only: %i[new create show]

    authorization_context 'email_service'
    authorization_required

    def index
      puts "\n ============= [domain_verifications_controller][index] ================\n"
      puts "\n =============  #{domains.inspect} ================\n"

      items_per_page = 10
      @paginatable_domains = Kaminari.paginate_array(domains, total_count: domains.count).page(params[:page]).per(items_per_page)
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
      rescue Exception => e
        flash[:error] = "Status Code: 500 : Error: #{e.message}"
    end

    def new
      puts "\n ============= [domain_verifications_controller] [new] ================\n"
      @rsa_key_length = ::EmailService::VerifiedDomain.key_length
      @configsets_collection = configset_names
      puts "\n ============= rsa_key_length : #{@rsa_key_length.inspect} ================\n"
      puts "\n ============= configsets_collection : #{@configsets_collection.inspect} ================\n"
    end

    def create

      begin
        domain_name = params[:verified_domain][:identity_name] || nil
        # dkim_enabled = params[:verified_domain][:dkim_enabled] || false

        # domain_signing_selector = params[:verified_domain][:dkim_signing_attributes][:domain_signing_selector] || nil
        # domain_signing_private_key = params[:verified_domain][:dkim_signing_attributes][:domain_signing_private_key] || nil
        # next_signing_key_length = params[:verified_domain][:dkim_signing_attributes][:next_signing_key_length] || 'RSA_1024_BIT'

        domain_signing_selector = params[:verified_domain][:domain_signing_selector] || nil
        domain_signing_private_key = params[:verified_domain][:domain_signing_private_key] || nil
        next_signing_key_length = params[:verified_domain][:next_signing_key_length] || 'RSA_1024_BIT'

        dkim_signing_attributes = {
          domain_signing_selector: domain_signing_selector,
          domain_signing_private_key: domain_signing_private_key,
          next_signing_key_length: next_signing_key_length,
        }
        tags = [{ "key1" => "value1"}, { "key2" => "value2"}]
        configset_name = params[:verified_domain][:configset_name] || nil

        Rails.logger.debug "\n **************** ---- INPUTS (create method) STARTS ---- **************** \n"
        Rails.logger.debug "\n **************** #{domain_name.inspect} **************** \n"
        Rails.logger.debug "\n **************** #{dkim_enabled.inspect} **************** \n"
        Rails.logger.debug "\n **************** #{configset_name.inspect} **************** \n"
        Rails.logger.debug "\n **************** #{domain_signing_selector.inspect} **************** \n"
        Rails.logger.debug "\n **************** #{domain_signing_private_key.inspect} **************** \n"
        Rails.logger.debug "\n **************** #{next_signing_key_length.inspect} **************** \n"
        Rails.logger.debug "\n **************** #{dkim_signing_attributes.inspect} **************** \n"
        Rails.logger.debug "\n **************** ---- INPUTS (create method) ENDS ----  **************** \n"


        if @verified_domain.valid?
          msg = process_domain_verification(domain_name, tags, dkim_signing_attributes, configset_name)
          flash[:info] = msg
          redirect_to plugin('email_service').domain_verifications_path and return
        else
          render :new and return
        end
        rescue Elektron::Errors::ApiResponse => e
          Rails.logger.error e.message
          flash[:error] = "[controller- create] : Status Code: (#{e.code}) : Error: #{e.message} "
        rescue Exception => e
          Rails.logger.error e.message
          flash[:error] = "[controller- create] : Status Code: 500- : Error: #{e.message}"
        redirect_to plugin('email_service').domain_verifications_path
      end

    end

    def show
      # domains
      # email_addresses


      puts "\n ==========================================================================\n"
      puts "\n ======[DomainVerificationsController][show]:PARAMS : #{params.inspect}====\n"
      puts "\n ======[DomainVerificationsController][show]:@verified_domain.inspect : #{@verified_domain.inspect}====\n"
      puts "\n ==========================================================================\n"

      Rails.logger.debug "\n [DomainVerificationsController][show] \n"
      begin
        @verified_identity = find_verified_identity_by_name(params[:domain], "DOMAIN")
        Rails.logger.debug "\n [DomainVerificationsController][find_verified_identity_by_name]:[params.inspect: \n [#{params.inspect}] \n"
        Rails.logger.debug "\n [DomainVerificationsController][find_verified_identity_by_name]:[@verified_identity.inspect] \n [#{@verified_identity.inspect}] \n"
      rescue Elektron::Errors::ApiResponse => e
        Rails.logger.error e.message
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
      rescue Exception => e
        Rails.logger.error e.message
        flash[:error] = "Status Code: 500 : Error: #{e.message}"
      end
    end

    def destroy
      identity = params[:domain] unless params[:domain].nil?
      status = delete_email_identity(domain)
      if status == "success"
        msg = "The identity #{domain} is removed"
        flash[:success] = msg
        redirect_to plugin('email_service').domain_verifications_path and return
      else
        msg = "Identity #{domain} removal failed : #{status}"
        flash[:error] = msg
      end
      rescue Elektron::Errors::ApiResponse => e
        Rails.logger.error e.message
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
      rescue Exception => e
        Rails.logger.error e.message
        flash[:error] = "Status Code: 500 : Error: #{e.message}"
      redirect_to plugin('email_service').domain_verifications_path
    end

    def verify_dkim

      identity = params[:domain]
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
      identity = params[:domain]
      dkim_status, dkim_attributes = get_dkim_attributes([domain])
      @dkim_enabled = is_dkim_enabled(dkim_attributes, domain)
      Rails.logger.info  "@dkim_enabled : #{@dkim_enabled} "
      if @dkim_enabled == false
        st = toggle_dkim(domain, true)
      end
      flash[:success] = "DKIM for #{domain} is activated"
      Rails.logger.debug   "DKIM for #{domain} is activated"
      redirect_to plugin('email_service').domain_verifications_path and return
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
        Rails.logger.error  "\n ********* [controller - activate_dkim] - #{e.inspect} \n ***********\n"
      rescue Exception => e
        flash[:error] = "Status Code: 500 : Error: #{e.message}"
        Rails.logger.error  "\n ********* [controller - activate_dkim] - #{e.inspect} \n ***********\n"
    end

    def deactivate_dkim

      puts "\n ==========================================================================\n"
      puts "\n ======[deactivate_dkim]=======PARAMS : #{params.inspect}=============================\n"
      puts "\n ==========================================================================\n"

      domain = params[:domain]
      begin
        sending_enabled, dkim_attributes = get_dkim_attributes(domain)
        if dkim_status
          toggle_dkim(domain, false)
          # @dkim_enabled = is_dkim_enabled(dkim_attributes, domain)
        end
        # if @dkim_enabled
        #   toggle_dkim(domain, false)
        # end
        flash[:success] = "DKIM for #{domain} is deactivated"

      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
      rescue Exception => e
        flash[:error] = "Status Code: 500 : Error: #{e.message}"
      end
      redirect_to plugin('email_service').domain_verifications_path and return
    end


    def process_domain_verification(domain, tags=[], dkim_signing_attributes={}, configuration_set_name="")

      status = nil
      status = create_email_identity_domain(domain, tags, dkim_signing_attributes, configuration_set_name)
      return status

    end

    private

      def domain_verification_form(attributes={})
        EmailService::VerifiedDomain.new(attributes)
      end

      def set_verified_domain
        @verified_domain = find_verified_domain(params[:domain])
      end

      def domain_verification_params
        if params.include?(:verified_domain)
          return params.require(:verified_domain).permit(:domain, :dkim_enabled, :tags, :dkim_signing_attributes, :domain_signing_private_key, :domain_signing_selector, :next_signing_key_length, :configuration_set_name)
        else
          {}
        end
      end

  end
end
