module EmailService
  class VerificationsController < ::EmailService::ApplicationController
    before_action :restrict_access
    
    def index
      creds = get_ec2_creds
      if creds.error.empty?
        @all_emails = list_verified_identities("EmailAddress")
        @verified_emails = get_verified_identities_by_status(@all_emails, "Success")
        @pending_emails  = get_verified_identities_by_status(@all_emails, "Pending")
        @failed_emails   = get_verified_identities_by_status(@all_emails, "Failed")
        @all_domains = list_verified_identities("Domain")
        @verified_domains = get_verified_identities_by_status(@all_domains, "Success")
      else
        flash[:error] = creds.error
      end

      
    end

    def new

    end
    
    def show

    end

    def create
      identity = params[:verified_email][:identity].to_s
      status = get_identity_verification_status(identity, "EmailAddress")
      logger.debug "email verification status : #{status}"
      if status == "success"
        msg= "This email address #{identity} is already verified."
        flash[:warning] = msg
      elsif status == "pending"
        msg = "verification eMail is already sent to #{identity}. Please check your email including Junk folder."
        flash[:warning] = msg
      else # if status == "failed"
        status = verify_identity(identity, "EmailAddress")
        if status == "success"
          msg = "Please check your eMail [#{identity}] including Junk folder."
          flash[:success] = msg
        else 
          msg = "Failed: #{status}"
          flash[:error] = msg
        end
      end
      logger.debug "CRONUS: DEBUG #{msg}"
      redirect_to({ action: :index } ) 
      
    end

    def destroy
      
      identity = params[:identity] unless params[:identity].nil?
      # logger.debug "CRONUS delete : #{params.inspect} IDENTITY: #{ identity }"
      status = remove_verified_identity(identity)

      @all_emails = list_verified_identities("EmailAddress")
      @verified_emails = get_verified_identities_by_status(@all_emails, "Success")
      
      # @pending_emails  = get_verified_identities_by_status(@all_emails, "Pending")
      # @failed_emails   = get_verified_identities_by_status(@all_emails, "Failed")

      if status == "success"
        msg = "The identity #{identity} is removed"
        flash[:success] = msg
      else 
        msg = "Identity #{identity} removal failed : #{status}"
        flash[:error] = msg
      end

      redirect_to({ action: :index } ) 
    end

  end
end