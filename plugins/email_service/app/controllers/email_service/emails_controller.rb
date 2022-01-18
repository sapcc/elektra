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
        # @send_stats = get_send_stats
        # @send_data = get_send_data
      else
        flash[:error] = "Err: #{creds.error}"
      end
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
      rescue Exception => e
        flash[:error] = "Status Code: 500 : Error: #{e.message}"
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

      # @plain_email_form = ::EmailService::Forms::PlainEmail.new(email_params)
      # puts @plain_email_form.show_attributes
      # @plain_email = ::EmailService::PlainEmail.new(email_params)
      # puts @plain_email
      # debugger
      # -----------------------
      status = ""
      @email = new_email(email_params)
      status = send_email(@email) unless @email.errors?      
      if status == "success"
        msg = "eMail sent successfully"
        flash[:success] = msg
        redirect_to plugin('email_service').emails_path and return
      elsif @email && @email.errors?
        msg = "error occured: #{ @email.errors }"
        flash[:warning] = msg
        render 'new'
      end
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
      rescue Exception => e
        flash[:error] = "Status Code: 500 : Error: #{e.message}"
      redirect_to plugin('email_service').emails_path
    end

    def email_params
      params.require(:email).permit(:source, :to_addr, :cc_addr, :bcc_addr, 
                                   :subject, :htmlbody, :textbody)
    end

  end
end

