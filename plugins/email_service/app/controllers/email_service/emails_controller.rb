module EmailService
  class EmailsController < ::EmailService::ApplicationController
    before_action :restrict_access

    authorization_context 'email_service'
    authorization_required

    def index
      creds = get_ec2_creds
      if creds.error.empty?
        @all_emails = list_verified_identities("EmailAddress")
        @verified_emails = get_verified_identities_by_status(@all_emails, "Success")
        @send_stats = get_send_stats
        @send_data = get_send_data
      else
        flash[:error] = "Err: #{creds.error}"
      end
    rescue Elektron::Errors::ApiResponse => e
      flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
    rescue Exception => e
      flash[:error] = "Status Code: 500 : Error: #{e.message}"
    end

    def stats
      creds = get_ec2_creds
      if creds.error.empty?
        @send_stats = get_send_stats
      else
        flash[:error] = creds.error
      end
    rescue Elektron::Errors::ApiResponse => e
      flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
    rescue Exception => e
      flash[:error] = "Status Code: 500 : Error: #{e.message}"
    end

    def info
      @creds = get_ec2_creds
      if @creds.error.empty? 
        @access = @creds.access
        @secret = @creds.secret
        @ses_client = create_ses_client

        @all_emails = list_verified_identities("EmailAddress")
        @verified_emails = get_verified_identities_by_status(@all_emails, "Success")
        @pending_emails  = get_verified_identities_by_status(@all_emails, "Pending")
        @failed_emails   = get_verified_identities_by_status(@all_emails, "Failed")
        @verified_emails_collection = get_verified_identities_collection(@verified_emails, "EmailAddress")

        @all_domains = list_verified_identities("Domain")
        @verified_domains = get_verified_identities_by_status(@all_domains, "Success")
        @pending_domains  = get_verified_identities_by_status(@all_domains, "Pending")
        @failed_domains   = get_verified_identities_by_status(@all_domains, "Failed")
        @verified_domains_collection = get_verified_identities_collection(@verified_domains, "Domain")
        
        @send_stats = get_send_stats
        @send_data = get_send_data
        @all_templates = get_all_templates

        @template_items_match = get_template_items
      else
        flash[:error] = creds.error
      end

      # authorization_context 'email_service'
      # authorization_required except: %i[]
      # action = "email_service:email_create"
      # @current_user.is_allowed?(action, @domain)
      # current_user.has_role?('email_user')
    rescue Elektron::Errors::ApiResponse => e
      flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
    rescue Exception => e
      flash[:error] = "Status Code: 500 : Error: #{e.message}"
    end

    def show
    end

    def new 
      @all_emails = list_verified_identities("EmailAddress")
      @verified_emails = get_verified_identities_by_status(@all_emails, "Success")
      @verified_emails_collection = get_verified_identities_collection(@verified_emails, "EmailAddress") unless @verified_emails.nil? || @verified_emails.empty?
      @all_domains = list_verified_identities("Domain")
      @verified_domains = get_verified_identities_by_status(@all_domains, "Success")
      @verified_domains_collection = get_verified_identities_collection(@verified_domains, "Domain") unless @verified_domains.nil? || @verified_domains.empty?
    rescue Elektron::Errors::ApiResponse => e
      flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
    rescue Exception => e
      flash[:error] = "Status Code: 500 : Error: #{e.message}"
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
    rescue Elektron::Errors::ApiResponse => e
      flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
    rescue Exception => e
      flash[:error] = "Status Code: 500 : Error: #{e.message}"
    end

    def email_params
      params.require(:email).permit(:source, :to_addr, :cc_addr, :bcc_addr, 
                                   :subject, :htmlbody, :textbody)
    end

  end
end

