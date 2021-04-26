# require 'logger'
module EmailService
  module AwsSesHelper

    def send_email(plain_email)
      status = ""
      ses_client = create_ses_client
      begin
        ses_client.send_email(
          destination: {
            to_addresses: plain_email.email.to_addr ,
            cc_addresses: plain_email.email.cc_addr ,
            bcc_addresses: plain_email.email.bcc_addr,
          },
          message: {
            body: {
              html: {
                charset: plain_email.email.encoding,
                data: plain_email.email.htmlbody
              },
              text: {
                charset: plain_email.email.encoding,
                data: plain_email.email.textbody
              }
            },
            subject: {
              charset: plain_email.email.encoding,
              data: plain_email.email.subject
            }
          },
          source: plain_email.email.source,
        )
        status = "success"
      rescue Aws::SES::Errors::ServiceError => error
        status = "#{error}"
        logger.debug "CRONUS : DEBUG : #{error}"
      end
      status 
    end

    def get_ec2_creds
      resp = services.email_service.get_aws_creds(current_user.id)
      keyhash = resp[:items][0]
      access = keyhash.access
      secret = keyhash.secret
      [access, secret]
    end

    def create_ses_client
      region = map_region(current_user.default_services_region)
      endpoint = current_user.service_url('email-aws')
      begin
        access, secret = get_ec2_creds
        credentials = Aws::Credentials.new(access, secret)
        ses_client = Aws::SES::Client.new(region: region, endpoint: endpoint, credentials: credentials)
      rescue Aws::SES::Errors::ServiceError => error
        puts "Error is : #{error}"
      end
    end

    def get_verified_emails_by_status(all_emails, status)
      result = []
      all_emails.each do | e |
        if e[:status] == status
          result.push(e)
        end
      end
      result
    end

    def verify_email(recipient)
      ses_client = create_ses_client
      if recipient != nil && ! recipient.include?("sap.com")
        begin
          ses_client.verify_email_identity({
          email_address: recipient
          })
          logger.debug "Verification email sent successfully to #{recipient}"
          redirect_to plugin('email_service').verifications_path
          flash.now[:success] = "Verification email sent successfully to #{recipient}"

        rescue Aws::SES::Errors::ServiceError => error
          logger.debug "Email verification failed. Error message: #{error}"
          redirect_to plugin('email_service').verifications_path  
          flash.now[:warning] = "Email verification failed. Error message: #{error}"
        end
      end
      if recipient.include?("sap.com")
        flash.now[:warning] = "sap.com domain email addresses are not allowed to verify as a sender(#{recipient})"
        logger.debug "sap.com domain email addresses are not allowed to verify as a sender(#{recipient})"
        redirect_to plugin('email_service').verifications_path  
      end
    end

    def list_verified_identities(id_type)
      attrs = Hash.new
      all_verified_emails = []
      begin
        ses_client = create_ses_client
        # Get up to 1000 identities
        ids = ses_client.list_identities({
          identity_type: id_type
        })
        id = 0
        ids.identities.each do |email|
          attrs = ses_client.get_identity_verification_attributes({
            identities: [email]
          })
          status = attrs.verification_attributes[email].verification_status
          # Add id to each entry of verified identities 
          id += 1
          identity_hash = {:id => id, :email => email, :status => status}
          all_verified_emails.push(identity_hash)
        end
      rescue Aws::SES::Errors::ServiceError => error
        logger.debug "error while listing verified emails. Error message: #{error}"
      end
      all_verified_emails
    end

    def remove_verified_identity(identity)
      ses = create_ses_client
      status = ""
        begin
          ses.delete_identity({
            identity: identity
          })
          status = "success"
         rescue Aws::SES::Errors::ServiceError => error
          status = "error: #{error}"
        end
        status 
    end

    def list_templates
      tmpl_hash = Hash.new
      templates = []
      begin
        ses_client = create_ses_client
        template_list = ses_client.list_templates({
          next_token: "",
          max_items: 10,
        })
        
        # if template_list.size > 0
        #   for index in 0 ... template_list.size - 1 
        #     resp = ses_client.get_template({
        #       template_name: template_list.templates_metadata[index].name,
        #     })
        #     tmpl_hash = { :id => index, :name => resp.template.template_name, :subject => resp.template.subject_part, :text_part => resp.template.text_part, :html_part => resp.template.html_part }
        #     templates.push(tmpl_hash)
        #   end 
        # end

        # logger.debug "CRONUS: DEBUG: REAL COUNT : #{template_list.templates_metadata.count} "  
        index = 0 
        # logger.debug "CRONUS: DEBUG: template_list SIZE : #{template_list.size}"
        while template_list.size > 0 && index < template_list.templates_metadata.count  
            resp = ses_client.get_template({
            template_name: template_list.templates_metadata[index].name,
            })
            tmpl_hash = { :id => index, :name => resp.template.template_name, :subject => resp.template.subject_part, :text_part => resp.template.text_part, :html_part => resp.template.html_part }
            templates.push(tmpl_hash)
            index = index + 1
            # logger.debug "CRONUS: DEBUG: RESP: #{resp}"
            # logger.debug "CRONUS: DEBUG: TMPL_HASH #{tmpl_hash}"
            # logger.debug "CRONUS: DEBUG: INDEX #{index}"
        end

      rescue Aws::SES::Errors::ServiceError => error
        msg = "Unable to fetch templates. Error message: #{error}"
        logger.debug "CRONUS: DEBUG: #{msg}"
        flash.now[:alert] = msg # TODO: fix this flash
      end
      templates
    end

    def find_template_by_name(name)
      @templates = list_templates
      # logger.debug "CRONUS: DEBUG: FT {@templates.size} #{@templates.size}"
      template = new_template({})
      @templates.each do |t|
        if t[:name] == name 
          template = new_template(t)
        end
      end
      template
    end

    def create_template(tmpl)
      status = " "
      ses_client = create_ses_client
      begin
        resp = ses_client.create_template({
          template: {
            template_name: tmpl.template.name,
            subject_part: tmpl.template.subject,
            text_part: tmpl.template.text_part,
            html_part: tmpl.template.html_part,
          },
        })
        msg = "Template is saved"
        status = "success"
      rescue Aws::SES::Errors::ServiceError => error
        msg = "Template not saved. Error message: #{error}"
        status = msg
      end
      logger.debug "CRONUS: DEBUG: #{msg} "
      status
    end

    def delete_template(tmpl_name)
      # name = params[:name]  
      status = " "
      ses_client = create_ses_client
      begin
        resp = ses_client.delete_template({
            template_name: tmpl_name,
        })
        status = "success"
      rescue Aws::SES::Errors::ServiceError => error
         msg = "Unable to delete template #{name}. Error message: #{error} "
        status = msg
        # redirect_to({ :controller => 'email_templates', :action=>'index' }, :notice => "#{error}")
      end
      # logger.debug "#{msg}"
      status
    end

    def update_template(template)
    end

    def send_templated_email(email, template)
    end

    def map_region(region)
      aws_region = " "
      case region
      when "na-us-1"
        aws_region = "us-east-1"
      when "na-us-2"
        aws_region = "us-east-2"
      when "na-us-3"
        aws_region = "us-west-2"
      when "ap-ae-1"
        aws_region = "ap-south-1"
      when "ap-jp-1"
        aws_region = "ap-northeast-1"
      when "ap-jp-2"
        aws_region = "ap-northeast-2"
      when "eu-de-1", "qa-de-1", "qa-de-2"
        aws_region = "eu-central-1"
      when "eu-nl-1"
        aws_region = "eu-west-1"
      when "na-ca-1"
        aws_region = "ca-central-1"
      when "la-br-1"
        aws_region = "sa-east-1"
      end
    end

  end
end


