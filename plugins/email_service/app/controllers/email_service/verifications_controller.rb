module EmailService
  class VerificationsController < ::EmailService::ApplicationController
    include AwsSesHelper
    include EmailHelper

    def index
      @all_emails = list_verified_identities("EmailAddress")
      @verified_emails = get_verified_emails_by_status(@all_emails, "Success")
      @pending_emails  = get_verified_emails_by_status(@all_emails, "Pending")
      @failed_emails   = get_verified_emails_by_status(@all_emails, "Failed")
    end

    def new

    end
    
    def show

    end

    def create
      sender = params[:verified_email][:sender].to_s
      status = isEmailVerified?(sender)
      logger.debug "email verification status : #{status}"
      if status == "success"
        msg= "This email address #{sender} is already verified."
        flash[:warning] = msg
      elsif status == "pending"
        msg = "verification eMail is already sent to #{sender}. Please check your email including Junk folder."
        flash[:warning] = msg
      else # if status == "failed"
        st = verify_email(sender)
        if st == "success"
          msg = "Please check your eMail [#{sender}] including Junk folder."
          flash[:success] = msg
        else 
          msg = "Failed: #{st}"
          flash[:error] = msg
        end
      end
      logger.debug "CRONUS: DEBUG #{msg}"
      redirect_to({ action: :index } ) 
      
    end

    def destroy
      
      identity = params[:email] unless params[:email].nil?
      # logger.debug "CRONUS delete : #{params.inspect} IDENTITY: #{ identity } "
      status = remove_verified_identity(identity)

      @all_emails = list_verified_identities("EmailAddress")
      @verified_emails = get_verified_emails_by_status(@all_emails, "Success")
      # @pending_emails  = get_verified_emails_by_status(@all_emails, "Pending")
      # @failed_emails   = get_verified_emails_by_status(@all_emails, "Failed")

      if status == "success"
        msg = "The identity #{identity} is removed"
        flash[:success] = msg
      else 
        msg = "Identity #{identity} removal failed : #{status}"
        flash[:error] = msg
      end
      
      # render action: :index
      redirect_to({ action: :index } ) 
    end

  end
end