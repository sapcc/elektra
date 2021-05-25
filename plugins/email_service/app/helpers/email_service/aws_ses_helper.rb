# require 'logger'
module EmailService
  module AwsSesHelper
    @encoding = "utf-8"

    ### EC2 CREDS ### 
    def get_ec2_creds
      aws_creds = services.email_service.aws_creds(current_user.id)
    end

    ### CREATE SES CLIENT ###
    def create_ses_client
      region = map_region(current_user.default_services_region)
      endpoint = current_user.service_url('email-aws')
      begin
        creds =  get_ec2_creds
        credentials = Aws::Credentials.new(creds.access, creds.secret)
        ses_client = Aws::SES::Client.new(region: region, endpoint: endpoint, credentials: credentials)
      rescue Aws::SES::Errors::ServiceError => error
        puts "Error is : #{error}"
      end
    end

    ## Send Plain eMail ##
    def send_email(plain_email)
      error = ""
      ses_client = create_ses_client
      
      begin
        resp = ses_client.send_email(
          destination: {
            to_addresses: plain_email.to_addr ,
            cc_addresses: plain_email.cc_addr ,
            bcc_addresses: plain_email.bcc_addr,
          },
          message: {
            body: {
              html: {
                charset: @encoding,
                data: plain_email.htmlbody
              },
              text: {
                charset: @encoding,
                data: plain_email.textbody
              }
            },
            subject: {
              charset: @encoding,
              data: plain_email.subject
            }
          },
          source: plain_email.source,
        )
      rescue Aws::SES::Errors::ServiceError => error
        logger.debug "CRONUS : DEBUG : ERROR: Send Plain eMail -#{plain_email.inspect} :-:  #{error}"
      end
      resp && resp.successful? ? "success" : error
    end
    # def send_email(plain_email)
    #   error = ""
    #   ses_client = create_ses_client
      
    #   begin
    #     resp = ses_client.send_email(
    #       destination: {
    #         to_addresses: plain_email.email.to_addr ,
    #         cc_addresses: plain_email.email.cc_addr ,
    #         bcc_addresses: plain_email.email.bcc_addr,
    #       },
    #       message: {
    #         body: {
    #           html: {
    #             charset: @encoding,
    #             data: plain_email.email.htmlbody
    #           },
    #           text: {
    #             charset: @encoding,
    #             data: plain_email.email.textbody
    #           }
    #         },
    #         subject: {
    #           charset: @encoding,
    #           data: plain_email.email.subject
    #         }
    #       },
    #       source: plain_email.email.source,
    #     )
    #   rescue Aws::SES::Errors::ServiceError => error
    #     logger.debug "CRONUS : DEBUG : ERROR: Send Plain eMail -#{plain_email.inspect} :-:  #{error}"
    #   end
    #   resp && resp.successful? ? "success" : error
    # end


    def send_templated_email(templated_email)
      error = ""
      resp = ""
      ses_client = create_ses_client
      begin
        resp = ses_client.send_templated_email({
          source: templated_email.source, # required
          destination: { # required
            to_addresses: templated_email.to_addr,
            cc_addresses: templated_email.cc_addr,
            bcc_addresses: templated_email.bcc_addr,
          },
          reply_to_addresses: [templated_email.reply_to_addr],
          return_path: templated_email.reply_to_addr,
          # source_arn: "",
          # return_path_arn: "",
          tags: [
            {
              name: "MessageTagName", # required
              value: "MessageTagValue", # required
            },
          ],
          configuration_set_name: templated_email.configset_name,
          template: templated_email.template_name, # required
          # template_arn: "",
          template_data: templated_email.template_data, # required
        })
      rescue Aws::SES::Errors::ServiceError => error
        logger.debug "CRONUS: DEBUG: #{error}"
        return error
      end
      # debugger
      resp && resp.successful? ? "success" : error
    end

    ### CONFIG SET ###

    def configset_create(name)
      status = ""

      begin
        ses_client = create_ses_client
        resp = ses_client.create_configuration_set({
          configuration_set: { # required
            name: name, # required
          },
        })
        status = "success" 
      rescue Aws::SES::Errors::ServiceError => error
        status = "#{error}"
        logger.debug "CRONUS: DEBUG: CONFIGSET: #{error}"
      end

      status
    end

    def get_configset
      status = ""
      configsets = []
      begin
        ses_client = create_ses_client
        resp = ses_client.list_configuration_sets({
          next_token: "",
          max_items: 1000,
        })

        for index in 0 ... resp.configuration_sets.size
          configsets << resp.configuration_sets[index].name
        end if resp.configuration_sets.size > 0

      rescue Aws::SES::Errors::ServiceError => error
        status = "#{error}"
        logger.debug "CRONUS: DEBUG: (AWS SES HELPER) CONFIGSET: #{error}"
      end

      configsets if configsets && !configsets.empty?
    # resp.configuration_sets #=> Array
    # resp.configuration_sets[0].name #=> String
    # resp.next_token #=> String
    end

    # Find existing config set
    def find_configset(name)
      resp = get_configset
      resp.configuration_sets.each do |config_set|
        logger.debug config_set[0].name
      end
    end

    def describe_configset(name)
      begin
        ses_client = create_ses_client
        resp = ses_client.describe_configuration_set({
          configuration_set_name: name, # required
          configuration_set_attribute_names: ["eventDestinations"], # accepts eventDestinations, trackingOptions, deliveryOptions, reputationOptions
        })
      rescue Aws::SES::Errors::ServiceError => error
        status = "#{error}"
        logger.debug "CRONUS: DEBUG: (AWS SES HELPER) DESCRIBE CONFIGSET: #{error}"
      end
      # resp.configuration_set.name #=> String
      # resp.event_destinations #=> Array
      # resp.event_destinations[0].name #=> String
      # resp.event_destinations[0].enabled #=> Boolean
      # resp.event_destinations[0].matching_event_types #=> Array
      # resp.event_destinations[0].matching_event_types[0] #=> String, one of "send", "reject", "bounce", "complaint", "delivery", "open", "click", "renderingFailure"
      # resp.event_destinations[0].kinesis_firehose_destination.iam_role_arn #=> String
      # resp.event_destinations[0].kinesis_firehose_destination.delivery_stream_arn #=> String
      # resp.event_destinations[0].cloud_watch_destination.dimension_configurations #=> Array
      # resp.event_destinations[0].cloud_watch_destination.dimension_configurations[0].dimension_name #=> String
      # resp.event_destinations[0].cloud_watch_destination.dimension_configurations[0].dimension_value_source #=> String, one of "messageTag", "emailHeader", "linkTag"
      # resp.event_destinations[0].cloud_watch_destination.dimension_configurations[0].default_dimension_value #=> String
      # resp.event_destinations[0].sns_destination.topic_arn #=> String
      # resp.tracking_options.custom_redirect_domain #=> String
      # resp.delivery_options.tls_policy #=> String, one of "Require", "Optional"
      # resp.reputation_options.sending_enabled #=> Boolean
      # resp.reputation_options.reputation_metrics_enabled #=> Boolean
      # resp.reputation_options.last_fresh_start #=> Time
    end

    def configset_destroy(name)
      status = ""
      begin
        ses_client = create_ses_client
        resp = ses_client.delete_configuration_set({
        configuration_set_name: name,
      })
        status = "success"
      rescue Aws::SES::Errors::ServiceError => error
        status = "#{error}"
        logger.debug "CRONUS: DEBUG: (AWS SES HELPER) CONFIGSET: #{error}"
      end
      status
    end
#### VERIFIED IDENTITIES ###

    # To get a list of email addresses by their verifcation status eg., "Success", "Pending", "Failed"
    def get_verified_emails_by_status(all_emails, status)
      result = []
      all_emails.each do | e |
        if e[:status] == status
          result.push(e)
        end
      end
      result
    end

    # Verify an email address with AWS SES excluding sap.com address
    def verify_email(recipient)
      ses_client = create_ses_client
      if recipient != nil && ! recipient.include?("sap.com")
        begin
          ses_client.verify_email_identity({
          email_address: recipient
          })
          logger.debug "Verification email sent successfully to #{recipient}"
          flash.now[:success] = "Verification email sent successfully to #{recipient}"
        rescue Aws::SES::Errors::ServiceError => error
          logger.debug "Email verification failed. Error message: #{error}"
          # redirect_to plugin('email_service').verifications_path  
          flash.now[:warning] = "Email verification failed. Error message: #{error}"
        end

      end
      if recipient.include?("sap.com")
        flash.now[:warning] = "sap.com domain email addresses are not allowed to verify as a sender(#{recipient})"
        logger.debug "sap.com domain email addresses are not allowed to verify as a sender(#{recipient})"
        # redirect_to plugin('email_service').verifications_path  
      end
      redirect_to plugin('email_service').verifications_path
    end

    # Lists verified identities so far id_type "Email Address" is used.
    def list_verified_identities(id_type)
      attrs = Hash.new
      verified_emails = []
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
          verified_emails.push(identity_hash)
        end
      rescue Aws::SES::Errors::ServiceError => error
        logger.debug "error while listing verified emails. Error message: #{error}"
      end
      verified_emails
    end

    # Removes verified identity
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

    #### TEMPLATES ###

    # Lists templates 
    def list_templates
      tmpl_hash = Hash.new
      templates = []
      begin
        ses_client = create_ses_client
        template_list = ses_client.list_templates({
          next_token: "",
          max_items: 10,
        })
       
        index = 0 
        # logger.debug "CRONUS: DEBUG: template_list SIZE : #{template_list.size}"
        while template_list.size > 0 && index < template_list.templates_metadata.count
            resp = ses_client.get_template({
            template_name: template_list.templates_metadata[index].name,
            })
            tmpl_hash = { :id => index, :name => resp.template.template_name, :subject => resp.template.subject_part, :text_part => resp.template.text_part, :html_part => resp.template.html_part }
            templates.push(tmpl_hash)
            index = index + 1
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

    def store_template(tmpl)
      status = " "
      ses_client = create_ses_client
      begin
        resp = ses_client.create_template({
          template: {
            template_name: tmpl.name,
            subject_part: tmpl.subject,
            text_part: tmpl.text_part,
            html_part: tmpl.html_part,
          },
        })
        msg = "Template is saved"
        status = "success"
      rescue Aws::SES::Errors::ServiceError => error
        msg = "Unable to save template: #{error}"
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

    ## Get Send Statistics

    def get_send_stats

      ses_client = create_ses_client
      stats_arr  = []
      
      begin
        resp = ses_client.get_send_statistics({})
        datapoints = resp.send_data_points

        index = 0
        while datapoints.size > 0 && index < datapoints.count
          # logger.debug "TIMESTAMP : #{datapoints[index].timestamp}"
          # logger.debug "DELIVERY_ATTEMPTS : #{datapoints[index].delivery_attempts}"
          # logger.debug "BOUNCES : #{datapoints[index].bounces}"
          # logger.debug "REJECTS : #{datapoints[index].rejects}"
          # logger.debug "COMPLAINTS : #{datapoints[index].complaints}"
          stats_hash = { timestamp: datapoints[index].timestamp, delivery_attempts: datapoints[index].delivery_attempts, bounces: datapoints[index].bounces, rejects: datapoints[index].rejects, complaints: datapoints[index].complaints }
          stats_arr.push(stats_hash)
          # TODO: SORT this data by date and humanize
          index += 1
        end
      rescue Aws::SES::Errors::ServiceError => error
        logger.debug "CRONUS SEND : #{error}" 
      end
      stats_arr
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


