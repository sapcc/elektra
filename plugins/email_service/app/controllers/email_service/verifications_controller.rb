module EmailService
  class VerificationsController < ::EmailService::ApplicationController
    before_action :restrict_access
    
    authorization_context 'email_service'
    authorization_required

    def index
      creds = get_ec2_creds
      if creds.error.empty?
        @all_emails = list_verified_identities("EmailAddress")
        @verified_emails = get_verified_identities_by_status(@all_emails, "Success")
        @pending_emails  = get_verified_identities_by_status(@all_emails, "Pending")
        @failed_emails   = get_verified_identities_by_status(@all_emails, "Failed")
        @all_domains = list_verified_identities("Domain")
        @verified_domains = get_verified_identities_by_status(@all_domains, "Success")
        items_per_page = 10
        @paginatable_emails = Kaminari.paginate_array(@all_emails, total_count: @all_emails.count).page(params[:page]).per(items_per_page)
      else
        flash[:error] = creds.error
      end
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
      rescue Exception => e
        flash[:error] = "Status Code: 500 : Error: #{e.message}"      
    end

    def new

    end
    
    def show

    end

    def create
      creds = get_ec2_creds
      already_verified_status, verified_status = ""
      identity = params[:verified_email][:identity].to_s
      if creds.error.empty?
        already_verified_status = get_identity_verification_status(identity, "EmailAddress")
        case already_verified_status
          when "success"
            msg= "This email address #{identity} is already verified."
            flash[:warning] = msg
          when "pending"
            msg= "Status: PENDING. Click on SES activation link sent to #{identity}"
            flash[:warning] = msg
          else 
            verified_status = verify_identity(identity, "EmailAddress")
            if verified_status == "success"
              msg = "Please check your eMail [#{identity}] including Junk folder and click on SES activation link."
              flash[:success] = msg
            else 
              flash[:error] = verified_status
              render :new and return
            end
        end
      else
        flash.now[:error] = creds.error.inspect
        render :new and return
      end
      logger.debug "CRONUS: DEBUG #{msg}"
      redirect_to plugin('email_service').verifications_path
    end

    def destroy
      identity = params[:identity] unless params[:identity].nil?
      status = remove_verified_identity(identity)
      @all_emails = list_verified_identities("EmailAddress")
      @verified_emails = get_verified_identities_by_status(@all_emails, "Success")
      if status == "success"
        msg = "The identity #{identity} is removed"
        flash[:success] = msg
      else 
        msg = "Identity #{identity} removal failed : #{status}"
        flash[:error] = msg
      end
      redirect_to plugin('email_service').verifications_path 
    end


    private

      def email_verification_params
        params.require(:verified_email).permit(:identity)
      end
  end
end