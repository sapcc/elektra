# require 'logger'
module EmailService
  module AwsSesHelper
    include TemplateHelper
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

    # Get send data
    def get_send_data
      resp_hash = {}
      ses_client = create_ses_client
      resp = ses_client.get_send_quota({
      })
      resp_hash = resp.to_h
    end

    ## Send Plain eMail ##
    def send_email(plain_email)
      error = ""
      begin
        ses_client = create_ses_client
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

    def send_templated_email(templated_email)
      error = ""
      resp = ""
      begin
        ses_client = create_ses_client
        resp = ses_client.send_templated_email({
          source: templated_email.source, 
          destination: {
            to_addresses: templated_email.to_addr,
            cc_addresses: templated_email.cc_addr,
            bcc_addresses: templated_email.bcc_addr,
          },
          reply_to_addresses: [templated_email.reply_to_addr],
          return_path: templated_email.reply_to_addr,
          tags: [
            {
              name: "MessageTagName", 
              value: "MessageTagValue",
            },
          ],
          configuration_set_name: templated_email.configset_name,
          template: templated_email.template_name, 
          template_data: templated_email.template_data,
        })
      rescue Aws::SES::Errors::ServiceError => error
        logger.debug "CRONUS: DEBUG: #{error}"
        # return error
      end
      resp && resp.successful? ? "success" : error
    end


    def get_dkim_attributes(identities=[])
      status = ""
      dkim_attributes = {}
      begin
        ses_client = create_ses_client
        dkim_attributes = ses_client.get_identity_dkim_attributes({
          identities: identities, 
        })
        status = "success" 
      rescue Aws::SES::Errors::ServiceError => error
        status = "#{error}"
        logger.debug "CRONUS: DEBUG: DKIM Attributes: #{error}"
      end
      return status, dkim_attributes
    end

    def get_dkim_tokens(resp, identity)
      dkim_token = resp[:dkim_attributes][identity][:dkim_tokens]
      return dkim_token
    end
    
    def is_dkim_enabled(resp, identity)
      dkim_enabled = resp[:dkim_attributes][identity][:dkim_enabled]
    end
    
    def get_dkim_verification_status(resp, identity)
      verification_status = resp[:dkim_attributes][identity][:dkim_verification_status] if resp
      return verification_status if verification_status
    end

    def verify_dkim(identity)
      status = ""
      begin
        ses_client = create_ses_client
        resp = ses_client.verify_domain_dkim({
          domain: identity, 
        })
        # logger.debug "verify dkim: #{resp} "
        status = "success"
        debugger
      rescue Aws::SES::Errors::ServiceError => error
        status = "#{error}"
        logger.debug "CRONUS: DEBUG: DKIM VERIFY: #{error}"
      end
      return status, resp
    end

    def enable_dkim(identity)
      status = ""
      begin
        ses_client = create_ses_client
        resp = ses_client.set_identity_dkim_enabled({
          dkim_enabled: true, 
          identity: identity, 
        }) 
        status = "success"
      rescue Aws::SES::Errors::ServiceError => error
        status = "#{error}"
        logger.debug "CRONUS: DEBUG: DKIM Enable: #{error}"
      end
      return status
    end
    
    def disable_dkim(identity)
      status = ""
      begin
        ses_client = create_ses_client
        resp = ses_client.set_identity_dkim_enabled({
          dkim_enabled: false, 
          identity: identity, 
        }) 
        status = "success"
      rescue Aws::SES::Errors::ServiceError => error
        status = "#{error}"
        logger.debug "CRONUS: DEBUG: DKIM Disable: #{error}"
      end
      return status
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

      # configsets if configsets && !configsets.empty?
      configsets && !configsets.empty? ? configsets : error
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

    # To get a list of verified identities
    def get_verified_identities_by_status(all_identities, status)
      result = []
      all_identities.each do | e |
        if e[:status] == status
          result.push(e)
        end
      end
      result
    end

    # Find an identity by name
    def find_verified_identity_by_name(identity, id_type)
      id_list = list_verified_identities(id_type)
      found = {}
      id_list.each do |item|
        if identity == item[:identity]
          found = item
        end
      end
      return found
    end

    # Verify Identity
    def verify_identity(identity, identity_type)
      resp = Aws::SES::Types::VerifyDomainIdentityResponse.new 
      status = ""
      ses_client = create_ses_client
      if identity.include?("sap.com") && identity_type == "EmailAddress"
        status = "sap.com domain email addresses are not allowed to verify as a sender(#{identity})"
      elsif identity == "" || !identity || identity == nil
        status = "#{identity_type} can't be empty"
      elsif identity != nil && identity_type == "Domain"
        begin
          resp = ses_client.verify_domain_identity({ domain: identity, })
        rescue Aws::SES::Errors::ServiceError => error
          resp = "#{identity_type} verification failed. Error message: #{error}"
        end
      elsif identity != nil && identity_type == "EmailAddress"
        begin
          ses_client.verify_email_identity({ email_address: identity, })
          status = "success"
        rescue Aws::SES::Errors::ServiceError => error
          status = "#{identity_type} verification failed. Error message: #{error}"  
        end
      end
      return identity_type == "Domain" ? resp : status 
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
          flash.now[:warning] = "Email verification failed. Error message: #{error}"
        end

      end
      if recipient.include?("sap.com")
        flash.now[:warning] = "sap.com domain email addresses are not allowed to verify as a sender(#{recipient})"
        logger.debug "sap.com domain email addresses are not allowed to verify as a sender(#{recipient})"
      end
    end

    def list_verified_identities(id_type)
      attrs = Hash.new
      verified_identities = []
      begin
        ses_client = create_ses_client
        # Get up to 1000 identities
        ids = ses_client.list_identities({
          identity_type: id_type
        })
        id = 0
        ids.identities.each do |identity|
          attrs = ses_client.get_identity_verification_attributes({
            identities: [identity]
          })
          status = attrs.verification_attributes[identity].verification_status
          token = attrs.verification_attributes[identity].verification_token
          status, dkim = get_dkim_attributes([identity])
          # logger.debug "dkim_attributes : #{dkim}"
          # logger.debug "dkim[:dkim_attributes] : #{dkim[:dkim_attributes]}"
          # logger.debug "dkim[:dkim_attributes][identity] : #{dkim[:dkim_attributes][identity]}"
          if dkim
            dkim_enabled = dkim[:dkim_attributes][identity][:dkim_enabled]
            dkim_tokens = dkim[:dkim_attributes][identity][:dkim_tokens]
            dkim_verification_status = dkim[:dkim_attributes][identity][:dkim_verification_status]
            # logger.debug "Status: #{status}"
            # logger.debug "dkim_enabled: #{dkim_enabled}"
            # logger.debug "dkim_tokens: #{dkim_tokens}"
            # logger.debug "dkim_verification_status: #{dkim_verification_status}"
          end
          id += 1
          identity_hash = {id: id, identity: identity, status: status,\
           verification_token: token, dkim_enabled: dkim_enabled, \
           dkim_tokens: dkim_tokens, dkim_verification_status: dkim_verification_status }
          #  logger.debug "identity_hash: #{identity_hash}"
          verified_identities.push(identity_hash)
        end
      rescue Aws::SES::Errors::ServiceError => error
        logger.debug "error while listing verified identities. Error message: #{error}"
      end
      verified_identities
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

   

    def get_send_stats
      stats_arr  = []
      begin
        ses_client = create_ses_client
        resp = ses_client.get_send_statistics({})
        datapoints = resp.send_data_points

        index = 0
        while datapoints.size > 0 && index < datapoints.count
          stats_hash = { timestamp: datapoints[index].timestamp, delivery_attempts: datapoints[index].delivery_attempts, bounces: datapoints[index].bounces, rejects: datapoints[index].rejects, complaints: datapoints[index].complaints }
          stats_arr.push(stats_hash)
          index += 1
        end
      rescue Aws::SES::Errors::ServiceError => error
        logger.debug "CRONUS SEND : #{error}" 
      end
      stats_arr.sort_by! { |hsh| hsh[:timestamp] } 
      stats_arr.reverse!
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