module EmailService
  class DomainVerificationsController < ::EmailService::ApplicationController

    before_action :check_ec2_creds_cronus_status
    before_action :check_verified_identity
    before_action :verified_domain, only: %i[new create show]

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
      @configsets_collection = list_configset_names
      puts "\n ============= rsa_key_length : #{@rsa_key_length.inspect} ================\n"
      puts "\n ============= configsets_collection : #{@configsets_collection.inspect} ================\n"
    end

    def create

      begin
        domain_name = params[:verified_domain][:identity] || nil
        dkim_enabled = params[:verified_domain][:dkim_enabled] || false
        domain_signing_selector = params[:verified_domain][:domain_signing_selector] || nil
        domain_signing_private_key = params[:verified_domain][:domain_signing_private_key] || nil
        next_signing_key_length = params[:verified_domain][:next_signing_key_length] || 'RSA_1024_BIT'
        dkim_signing_attributes = {
          domain_signing_selector: domain_signing_selector,
          domain_signing_private_key: domain_signing_private_key,
          next_signing_key_length: next_signing_key_length,
        }
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
          msg = process_domain_verification(domain_name, dkim_enabled, tags, dkim_signing_attributes, configset_name)
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
      domains
      # email_addresses

      Rails.logger.debug "\n [DomainVerificationsController][show] \n"
      begin
        @verified_identity = find_verified_identity_by_name(params[:identity], "DOMAIN")
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
      identity = params[:identity] unless params[:identity].nil?
      status = delete_email_identity(identity)
      if status == "success"
        msg = "The identity #{identity} is removed"
        flash[:success] = msg
        redirect_to plugin('email_service').domain_verifications_path and return
      else
        msg = "Identity #{identity} removal failed : #{status}"
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

      identity = params[:identity]
      status, resp = start_dkim_verification(identity)
      if status.include?("success")
        flash[:success] = "DKIM verification is initiated for [#{identity}]."
      else
        flash[:error] = "Unable to initiate DKIM verification for [#{identity}]. ERROR: #{status}"
        Rails.logger.error status
      end
      redirect_to plugin('email_service').domain_verifications_path

    end

    def activate_dkim
      identity = params[:identity]
      dkim_status, dkim_attributes = get_dkim_attributes([identity])
      @dkim_enabled = is_dkim_enabled(dkim_attributes, identity)
      Rails.logger.info  "@dkim_enabled : #{@dkim_enabled} "
      if @dkim_enabled == false
        st = toggle_dkim(identity, true)
      end
      flash[:success] = "DKIM for #{identity} is activated"
      Rails.logger.debug   "DKIM for #{identity} is activated"
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

      identity = params[:identity]
      begin
        sending_enabled, dkim_attributes = get_dkim_attributes(identity)
        if dkim_status
          toggle_dkim(identity, false)
          # @dkim_enabled = is_dkim_enabled(dkim_attributes, identity)
        end
        # if @dkim_enabled
        #   toggle_dkim(identity, false)
        # end
        flash[:success] = "DKIM for #{identity} is deactivated"

      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
      rescue Exception => e
        flash[:error] = "Status Code: 500 : Error: #{e.message}"
      end
      redirect_to plugin('email_service').domain_verifications_path and return
    end


    def process_domain_verification(domain_name, dkim_enabled=false, tags=[], dkim_signing_attributes={}, configset_name="")

      status = nil
      status = create_email_identity_domain(domain_name, tags, dkim_signing_attributes, configset_name)
      return status

    end

    private
      def domain_verification_params
        if params.include?(:verified_domain)
          return params.require(:verified_domain).permit(:identity, :dkim_enabled, :tags, :domain_signing_private_key, :domain_signing_selector, :next_signing_key_length, :configset_name)
        else
          {}
        end
      end

      def domain_verification_form(attributes={})
        EmailService::VerifiedDomain.new(attributes)
      end

      def verified_domain
        @verified_domain = domain_verification_form(domain_verification_params)
      end

  end
end
