module EmailService
  class VerificationsController < ::EmailService::ApplicationController
    include AwsSesHelper
    include EmailHelper

    def index
      @all_emails = list_verified_identities("EmailAddress")
      @verified_emails = get_verified_emails_by_status(@all_emails, "Success")
      @pending_emails  = get_verified_emails_by_status(@all_emails, "Pending")
      @failed_emails   = get_verified_emails_by_status(@all_emails, "Failed")
      # flash.now[:success] = @msg.nil? ? " oops ... from controller itself" : @msg
      # flash.now[:success] = "Verification emails are getting rendered." # works

      # @verified_emails = []
      # @pending_emails = []
      # @failed_emails = []

      # v_test = { id: 200, email: "abc@kyc.com", status: "Success"}
      # @verified_emails.push(v_test)
      # p_test = { id: 201, email: "cdf@lmn.com", status: "Pending"}
      # @pending_emails.push(p_test)
      # f_test = { id: 202, email: "ghi@opq.com", status: "Failed"}
      # @failed_emails.push(f_test)
      # # flash.now[:notice] = "This is how a notice looks like.#{@verified_emails.inspect}"
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

      render action: :index

    end

  end
end