module EmailService
  class DomainVerificationsController < ::EmailService::ApplicationController
    before_action :restrict_access
    before_action :check_user_creds_roles
    before_action :verified_domain, only: %i[new create]

    authorization_context 'email_service'
    authorization_required
    
    def index
      # @all_domains = list_verified_identities("Domain")
      # @verified_domains = get_verified_identities_by_status(@all_domains, "Success")
      # @pending_domains  = get_verified_identities_by_status(@all_domains, "Pending")
      # @failed_domains   = get_verified_identities_by_status(@all_domains, "Failed")
      items_per_page = 10
      @paginatable_domains = Kaminari.paginate_array(all_domains, total_count: all_domains.count).page(params[:page]).per(items_per_page)
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
      rescue Exception => e
        flash[:error] = "Status Code: 500 : Error: #{e.message}"
    end

    def new; end
    
    def create
      dkim_enabled = params[:verified_domain][:dkim_enabled] || nil
      domain_name = params[:verified_domain][:identity] || nil 
      if @verified_domain.valid?
        msg = process_domain_verification(domain_name, dkim_enabled)
        flash[:warning] = msg
        redirect_to plugin('email_service').domain_verifications_path and return
      else
        render :new and return
      end
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
      rescue Exception => e
        flash[:error] = "Status Code: 500 : Error: #{e.message}"

    end

    def show
      @verified_identity = find_verified_identity_by_name(params[:identity], "Domain")
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
      rescue Exception => e
        flash[:error] = "Status Code: 500 : Error: #{e.message}"
    end

    def destroy
      identity = params[:identity] unless params[:identity].nil?
      status = remove_verified_identity(identity)
      if status == "success"
        msg = "The identity #{identity} is removed"
        flash[:success] = msg
        redirect_to plugin('email_service').domain_verifications_path and return 
      else 
        msg = "Identity #{identity} removal failed : #{status}"
        flash[:error] = msg
      end
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
      rescue Exception => e
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
      end
      redirect_to plugin('email_service').domain_verifications_path

    end

    def activate_dkim
      identity = params[:identity]
      dkim_status, dkim_attributes = get_dkim_attributes([identity])
      @dkim_enabled = is_dkim_enabled(dkim_attributes, identity)
      Rails.logger.info  "@dkim_enabled : #{@dkim_enabled} "
      if @dkim_enabled == false
        st = enable_dkim(identity)
      end
      # @all_domains = list_verified_identities("Domain")
      # @verified_domains = get_verified_identities_by_status(@all_domains, "Success")
      flash[:success] = "DKIM for #{identity} is activated"
      redirect_to plugin('email_service').domain_verifications_path and return
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"  
      rescue Exception => e
        flash[:error] = "Status Code: 500 : Error: #{e.message}"

    end

    def deactivate_dkim
      identity = params[:identity]
      dkim_status, dkim_attributes = get_dkim_attributes([identity])
      if dkim_status == "success"
        @dkim_enabled = is_dkim_enabled(dkim_attributes, identity)
      end
      if @dkim_enabled
        disable_dkim(identity)
      end
      # @all_domains = list_verified_identities("Domain")
      # @verified_domains = get_verified_identities_by_status(@all_domains, "Success")
      flash[:success] = "DKIM for #{identity} is deactivated"
      redirect_to plugin('email_service').domain_verifications_path and return
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
      rescue Exception => e
        flash[:error] = "Status Code: 500 : Error: #{e.message}"
      
    end


    def process_domain_verification(domain_name, dkim_enabled=false)

      status = get_identity_verification_status(domain_name, "Domain")
      if status == "success"
        msg= "This domain address #{domain_name} is already verified."
      elsif status == "pending"
        msg = "You need to create a TXT record for your domain with the verification token. Please click on Show details of your domain under menu"
      else
        resp = verify_identity(domain_name, "Domain")
        if resp.include?('verification failed')
          msg = resp
        elsif resp.verification_token 
          msg = "Verification Token is: #{resp.verification_token}"
          unless !dkim_enabled
            status, resp = verify_dkim(domain_name)
            msg+= resp
          end
        end
      end
      return msg
    end

    private
      def domain_verification_params
        if params.include?(:verified_domain)
          return params.require(:verified_domain).permit(:identity, :dkim_enabled)
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
