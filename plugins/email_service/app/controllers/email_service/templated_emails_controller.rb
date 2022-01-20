module EmailService
  class TemplatedEmailsController < ::EmailService::ApplicationController
    before_action :restrict_access

    authorization_context 'email_service'
    authorization_required
    
    # def index
    #   creds = get_ec2_creds
    #   if creds.error.empty?
    #     @all_emails = list_verified_identities("EmailAddress")
    #     @verified_emails = get_verified_identities_by_status(@all_emails, "Success")
    #     # @pending_emails  = get_verified_identities_by_status(@all_emails, "Pending")
    #     # @failed_emails   = get_verified_identities_by_status(@all_emails, "Failed")
    #     @configsets = list_configset_names
    #   else
    #     msg = "EC2 Credentials #{ creds.error }. "
    #     # msg+= "Open your web-console and execute `openstack ec2 credentials create` command"
    #     flash[:warning] = msg
    #   end
    # rescue Elektron::Errors::ApiResponse => e
    #   flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
    # rescue Exception => e
    #   flash[:error] = "Status Code: 500 : Error: #{e.message}"
    # end

    def new
      creds = get_ec2_creds
      if creds.error.empty?
        @all_emails = list_verified_identities("EmailAddress")
        @verified_emails = get_verified_identities_by_status(@all_emails, "Success")
        @verified_emails_collection = get_verified_identities_collection(@verified_emails, "EmailAddress")
        @templates = get_all_templates
        @templates_collection = get_templates_collection(@templates) if @templates && !@templates.empty?
        @configsets = list_configset_names

      else
        flash[:error] = creds.error
      end
    rescue Elektron::Errors::ApiResponse => e
      flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
    rescue Exception => e
      flash[:error] = "Status Code: 500 : Error: #{e.message}"
    end

    def create
      status = ""
      @all_emails = list_verified_identities("EmailAddress")
      @verified_emails = get_verified_identities_by_status(@all_emails, "Success") if @all_emails && !@all_emails.empty?
      @configsets = list_configset_names
      @templates = get_all_templates
      @verified_emails_collection = get_verified_identities_collection(@verified_emails, "EmailAddress")
      @templates_collection = get_templates_collection(@templates) if @templates && !@templates.empty?
      @templated_email = new_templated_email(templated_email_params)

      if @templated_email.errors?
        @templated_email.errors.each do | err |
          flash[:error] = "Field: #{err[:name]}, error: #{err[:message]}"
        end
        render "edit", locals: {data: {modal: true}, email: @templated_email } and return
      else 
        status = send_templated_email(@templated_email)
      end

      if status == "success"
        msg = "eMail sent successfully"
        flash[:success] = msg 
        redirect_to plugin('email_service').emails_path and return
      else 
        msg = "error occured: #{status}"   
        flash.now[:error] = msg 
        render "edit", locals: {data: {modal: true} } and return
      end

      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
      rescue Exception => e
        flash[:error] = "Status Code: 500 : Error: #{e.message}"
      redirect_to plugin('email_service').emails_path

    end

    def edit
      creds = get_ec2_creds
      if creds.error.empty?
        @all_emails = list_verified_identities("EmailAddress")
        @verified_emails = get_verified_identities_by_status(@all_emails, "Success")
        @configsets = list_configset_names
        @templates = get_all_templates
        @verified_emails_collection = get_verified_identities_collection(@verified_emails, "EmailAddress")
        @templates_collection = get_templates_collection(@templates) if @templates && !@templates.empty?
      else
        flash[:error] = creds.error
      end
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
      rescue Exception => e
        flash[:error] = "Status Code: 500 : Error: #{e.message}"
    end

    def templated_email_params
      params.require(:email).permit(:source, :to_addr, :cc_addr, :bcc_addr,\
        :reply_to_addr, :template_name, :template_data, :configset_name)
    end

  end
end
