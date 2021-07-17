module EmailService
  class DomainVerificationsController < ::EmailService::ApplicationController
    include AwsSesHelper
    include EmailHelper

    def index
      @all_domains = list_verified_identities("Domain")
      @verified_domains = get_verified_identities_by_status(@all_domains, "Success")
      @pending_domains  = get_verified_identities_by_status(@all_domains, "Pending")
      @failed_domains   = get_verified_identities_by_status(@all_domains, "Failed")
    end

    def new; end
    
    def show
      @verified_identity = find_verified_identity_by_name(params[:identity], "Domain")
    end

    def create
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