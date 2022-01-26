module EmailService
  class DomainVerificationsController < ::EmailService::ApplicationController
    before_action :restrict_access

    authorization_context 'email_service'
    authorization_required
    
    def index
      @all_domains = list_verified_identities("Domain")
      @verified_domains = get_verified_identities_by_status(@all_domains, "Success")
      @pending_domains  = get_verified_identities_by_status(@all_domains, "Pending")
      @failed_domains   = get_verified_identities_by_status(@all_domains, "Failed")
      items_per_page = 10
      @paginatable_domains = Kaminari.paginate_array(@all_domains, total_count: @all_domains.count).page(params[:page]).per(items_per_page)
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
      rescue Exception => e
        flash[:error] = "Status Code: 500 : Error: #{e.message}"
    end

    def new; end
    
    def show
      @verified_identity = find_verified_identity_by_name(params[:identity], "Domain")
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
      rescue Exception => e
        flash[:error] = "Status Code: 500 : Error: #{e.message}"
    end

    # def verify_dkim
    #   identity = params[:identity]
    #   st, dkim = verify_dkim(identity)
    #   redirect_to({ action: :index } )  
    # rescue Elektron::Errors::ApiResponse => e
    #   flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
    # rescue Exception => e
    #   flash[:error] = "Status Code: 500 : Error: #{e.message}"
    # end
    
    def activate_dkim
      identity = params[:identity]
      dkim_status, dkim_attributes = get_dkim_attributes([identity])
      @dkim_enabled = is_dkim_enabled(dkim_attributes, identity)
      logger.debug "@dkim_enabled : #{@dkim_enabled} "
      if @dkim_enabled == false
        st = enable_dkim(identity)
      end
      @all_domains = list_verified_identities("Domain")
      @verified_domains = get_verified_identities_by_status(@all_domains, "Success")
      flash[:success] = "DKIM for #{identity} is activated"
      redirect_to({ action: :index } )  
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
      if @dkim_enabled == true
        disable_dkim(identity)
      end
      @all_domains = list_verified_identities("Domain")
      @verified_domains = get_verified_identities_by_status(@all_domains, "Success")
      flash[:success] = "DKIM for #{identity} is deactivated"
      redirect_to({ action: :index } )  
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
      rescue Exception => e
        flash[:error] = "Status Code: 500 : Error: #{e.message}"
    end

    def create
      dkim_enabled = params[:verified_domain][:dkim_enabled].to_s
      domain_name = params[:verified_domain][:identity].to_s
      status = get_identity_verification_status(domain_name, "Domain")
      if status == "success"
        msg= "This domain address #{domain_name} is already verified."
        flash[:warning] = msg
      elsif status == "pending"
        msg = "You need to create a TXT record for your domain with the verification token. Please click on Show details of your domain under menu"
        flash[:warning] = msg
      else
          resp = verify_identity(domain_name, "Domain")
        if resp.include?('verification failed')
          flash[:error] = resp
        elsif resp.verification_token
          msg = "Verification Token is: #{resp.verification_token}"
          verify_dkim(params[:verified_domain][:identity])
          flash[:success] = msg
        end
      end
      redirect_to({ action: :index } )  
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
      else 
        msg = "Identity #{identity} removal failed : #{status}"
        flash[:error] = msg
      end
      @all_domains = list_verified_identities("Domain")
      @verified_domains = get_verified_identities_by_status(@all_domains, "Success")
      redirect_to({ action: :index } ) 
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
      rescue Exception => e
        flash[:error] = "Status Code: 500 : Error: #{e.message}"
    end

    private
      def domain_verification_params
        params.require(:verified_domain).permit(:identity, :dkim_enabled)
      end

  end
end
