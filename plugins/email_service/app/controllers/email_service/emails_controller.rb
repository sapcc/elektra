module EmailService
  class EmailsController < ::EmailService::ApplicationController
    before_action :restrict_access

    def index
        creds = get_ec2_creds
        if creds.error.empty?
          @all_emails = list_verified_identities("EmailAddress")
          @verified_emails = get_verified_identities_by_status(@all_emails, "Success")
          @send_stats = get_send_stats
          @send_data = get_send_data
        else
          flash[:error] = creds.error
        end

        # if current_user.has_role?('email_admin')
        #   flash[:info] = "email_admin role is enabled"
        # else
        #   flash[:warning] = "email_admin role is not enabled"
        # end
    end

    def stats
      creds = get_ec2_creds
      if creds.error.empty?
        @send_stats = get_send_stats
      else
        flash[:error] = creds.error
      end
    end

    def info
      creds = get_ec2_creds
      if creds.error.empty? 
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
      else
        flash[:error] = creds.error
      end

      # authorization_context 'email_service'
      # authorization_required except: %i[]
      # action = "email_service:email_create"
      # @current_user.is_allowed?(action, @domain)
      # current_user.has_role?('email_user')

    end

    def show
    end

    def new 
      @all_emails = list_verified_identities("EmailAddress")
      @verified_emails = get_verified_identities_by_status(@all_emails, "success")
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
