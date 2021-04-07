module EmailService
  class VerificationsController < ::EmailService::ApplicationController
    include AwsSesHelper
    include EmailHelper

    def index
      @verified_emails, @pending_emails = verified_emails
      v_test = { id: 249, email: "sirajudheenam@gmail.com", status: "Success"}
      @verified_emails.push(v_test)
      # flash.now[:notice] = "This is how a notice looks like.#{@verified_emails.inspect}"
    end


    def new

    end
    def show

    end
    def create
      sender = params[:verified_email][:sender].to_s
      logger.debug "all parameters (PARAMS): #{params.inspect}"
      logger.debug "VERIFIED eMail (PARAMS): #{params[:verified_email][:sender]}"
      status = isEmailVerified?(sender)
      logger.debug "email verification status : #{status}"
      flash.now[:notice] = "email verification status : #{status}"
      if status == "success"
        logger.debug "This email address is already verified : #{sender}"
        flash.now[:success] = "This email address is already verified : #{sender}"
      elsif status == "pending"
        logger.debug "verification eMail is already sent to this email address : #{sender}"
        flash.now[:error] = "verification eMail is already sent to this email address : #{sender}. Please click the link on the email to verify"
      else
        verify_email(sender)
        flash.now[:success] = "Verification email is on its way to: #{sender}"
      end
    end

    def destroy
      identity = params[:id]
      logger.debug "Destroy method: PARAMS :: #{params}"
      logger.debug "IDENTITY :: #{identity}"
      # status = remove_verified_identity(identity)
      # logger.debug "Delete status : #{status}"
    end

  end
end