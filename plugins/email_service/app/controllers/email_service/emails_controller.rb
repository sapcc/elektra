module EmailService
  class EmailsController < ::EmailService::ApplicationController

    def index

      @all_emails = list_verified_identities("EmailAddress")
      @verified_emails = get_verified_emails_by_status(@all_emails, "Success")
      @pending_emails  = get_verified_emails_by_status(@all_emails, "Pending")
      @failed_emails   = get_verified_emails_by_status(@all_emails, "Failed")
      @send_stats = get_send_stats
    end

    def stats
      @send_stats = get_send_stats
    end

    def info
      creds = get_ec2_creds
      @access = creds.access
      @secret = creds.secret
      @ses_client = create_ses_client

      @all_emails = list_verified_identities("EmailAddress")
      @verified_emails = get_verified_emails_by_status(@all_emails, "Success")
      @pending_emails  = get_verified_emails_by_status(@all_emails, "Pending")
      @failed_emails   = get_verified_emails_by_status(@all_emails, "Failed")

      @send_stats = get_send_stats

      logger.debug "CRONUS: CONTROLLER : INSPECT #{@send_stats.inspect}"

    end

    def show
    end

    def new 
      @all_emails = list_verified_identities("EmailAddress")
      @verified_emails = get_verified_emails_by_status(@all_emails, "Success")

      @e_collection = get_verified_email_collection(@verified_emails) unless @verified_emails.nil? || @verified_emails.empty?
 
    end


    def create
      status = ""
      @email = new_email(email_params)
      status = send_email(@email) unless @email.errors?


      # result = email_to_array(@email)
      # status = send_email(result)
      # debugger
      

      if status == "success"
        msg = "eMail sent successfully"
        flash[:success] = msg
        redirect_to plugin('email_service').emails_path
      elsif @email && @email.errors?
        msg = "error occured: #{ @email.errors }"
        flash[:warning] = msg
        render 'new'
      end
      logger.debug "CRONUS DEBUG: #{msg}"

    end

    def email_params
      params.require(:email).permit(:source, :to_addr, :cc_addr, :bcc_addr, 
                                   :subject, :htmlbody, :textbody)
      
      # unless params['email'].blank?
      #   email = params.clone.fetch('email', {})
      #   return email
      # end
      # return {}
    end


  end
end
