module EmailService
  class EmailsController < ::EmailService::ApplicationController

    def index
      @all_emails = list_verified_identities("EmailAddress")
      @verified_emails = get_verified_identities_by_status(@all_emails, "Success")

      @send_stats = get_send_stats
      @send_data = get_send_data
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
      @verified_emails = get_verified_identities_by_status(@all_emails, "Success")
      @pending_emails  = get_verified_identities_by_status(@all_emails, "Pending")
      @failed_emails   = get_verified_identities_by_status(@all_emails, "Failed")

      @send_stats = get_send_stats
      @send_data = get_send_data

      @all_templates = get_all_templates
    end

    def show
    end

    def new 
      @all_emails = list_verified_identities("EmailAddress")
      @verified_emails = get_verified_identities_by_status(@all_emails, "Success")
      @verified_emails_collection = get_verified_identities_collection(@verified_emails, "EmailAddress") unless @verified_emails.nil? || @verified_emails.empty?
    end
    

    def create
      status = ""
      @email = new_email(email_params)
      status = send_email(@email) unless @email.errors?      
      if status == "success"
        msg = "eMail sent successfully"
        flash[:success] = msg
        redirect_to plugin('email_service').emails_path
      elsif @email && @email.errors?
        msg = "error occured: #{ @email.errors }"
        flash[:warning] = msg
        render 'new'
      end
    end

    def email_params
      params.require(:email).permit(:source, :to_addr, :cc_addr, :bcc_addr, 
                                   :subject, :htmlbody, :textbody)
    end

  end
end
