module EmailService
  class DomainVerificationsController < ::EmailService::ApplicationController
    # before_action :restrict_access

    def index
      creds = get_ec2_creds
      if creds.error.empty?
        @all_domains = list_verified_identities("Domain")
        @verified_domains = get_verified_identities_by_status(@all_domains, "Success")
        @pending_domains  = get_verified_identities_by_status(@all_domains, "Pending")
        @failed_domains   = get_verified_identities_by_status(@all_domains, "Failed")
        # identities_collection = get_verified_identities_collection(@verified_domains, "Domain")
        # dkim_status, @dkim_attributes = get_dkim_attributes(identities_collection)
      else
        flash[:error] = creds.error
      end


    end

    def new; end
    
    def show
      identity = params[:identity]
      @verified_identity = find_verified_identity_by_name(identity, "Domain")
    end

    def verify_dkim
      identity = params[:identity]
      st, dkim = verify_dkim(identity)
      logger.debug "DKIM tokens : #{dkim.dkim_tokens}"
      redirect_to({ action: :index } )  
    end
    def activate_dkim
      identity = params[:identity]
      dkim_status, dkim_attributes = get_dkim_attributes([identity])
      logger.debug "dkim_status : #{dkim_status} :  dkim_attributes : #{dkim_attributes.inspect} "
      @dkim_enabled = is_dkim_enabled(dkim_attributes, identity)
      logger.debug "@dkim_enabled : #{@dkim_enabled} "
      if @dkim_enabled == false
        st = enable_dkim(identity)
      end
      @all_domains = list_verified_identities("Domain")
      @verified_domains = get_verified_identities_by_status(@all_domains, "Success")
      flash[:success] = "DKIM for #{identity} is activated"
      redirect_to({ action: :index } )  
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
    end

    def create
      logger.debug "DKIM Enabled: #{params[:verified_domain][:dkim_enabled].to_s}"
      # DKIM Enabled: true
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
    end

    def destroy
      
      identity = params[:identity] unless params[:identity].nil?
      logger.debug "Identity is : #{identity}"
      # debugger
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
    end

  end
end