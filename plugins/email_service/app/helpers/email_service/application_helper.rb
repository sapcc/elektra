module EmailService
  module ApplicationHelper
    
    @encoding = "utf-8"

    # https://docs.aws.amazon.com/sdk-for-ruby/v2/api/Aws/SES/Client.html#update_configuration_set_event_destination-instance_method
    
    #
    # PlainEmail
    #

    # send plain email
    def send_plain_email(plain_email)
      error = ""
      begin
        resp = ses_client.send_email(
          destination: {
            to_addresses: plain_email.to_addr,
            cc_addresses: plain_email.cc_addr,
            bcc_addresses: plain_email.bcc_addr,
          },
          message: {
            body: {
              html: {
                charset: @encoding,
                data: plain_email.html_body
              },
              text: {
                charset: @encoding,
                data: plain_email.text_body
              }
            },
            subject: {
              charset: @encoding,
              data: plain_email.subject
            }
          },
          source: plain_email.source,
        )
        audit_logger.info(current_user.id, 'has sent email to', plain_email.to_addr,plain_email.cc_addr, plain_email.bcc_addr)
      rescue Aws::SES::Errors::ServiceError => e
        error = e
        logger.debug "CRONUS : sending plain email  #{error}"
      end

      return resp && resp.successful? ? "success" : error

    end

    #
    # TemplatedEmail
    #

    # send a templated email
    def send_templated_email(templated_email)

      begin
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
        audit_logger.info(current_user.id, 'has sent templated email from the template', \
        templated_email.template_name,  'to', templated_email.to_addr, \
        templated_email.cc_addr, templated_email.bcc_addr, 'with the template data', templated_email.template_data )
      rescue Aws::SES::Errors::ServiceError => error
        logger.debug "CRONUS: DEBUG: sending templated email #{error}"
      end

      return resp && resp.successful? ? "success" : error

    end

    #
    # Templates
    #

    # WIP
    # Attempt to parse using regex the template data
    def get_template_items
      template_regex = /\{{\K[^\s}}]+(?=}})/
      subject = "Subscription Preferences for {{contact.firstName}} {{contact.lastName}}"
      html_part = "<!doctype html><html><head><meta charset='utf-8'></head><body><h1>Your Preferences</h1> <p>You have indicated that you are interested in receiving information about the following subjects:</p> <ul> {{#each subscription}} <li>{{interest}}</li> {{/each}} </ul> <p>You can change these settings at any time by visiting the <a href=https://www.example.com/preferences/i.aspx?id={{meta.userId}}> Preference Center</a>.</p></body></html>"
      text_part = "Your Preferences\n\nYou have indicated that you are interested in receiving information about the following subjects:\n {{#each subscription}} - {{interest}}\n {{/each}} \nYou can change these settings at any time by visiting the Preference Center at https://www.example.com/prefererences/i.aspx?id={{meta.userId}}"
      # to get first occurance
      # @subject_match = subject.match(template_regex)
      # to get all occurances
      @subject_match = subject.scan(template_regex)
      @html_part_match = html_part.scan(template_regex)
      @text_part_match = text_part.scan(template_regex)
    end

    # Get template names as a collection to be rendered on form
    def get_templates_collection(templates)
      templates_collection = []
      if !templates.empty?
        templates.each do |template|
          templates_collection << template[:name]
        end
      end
      templates_collection
    end
    
    # list first 10 templates
    def list_templates(token="")
      tmpl_hash = Hash.new
      templates = []
      next_token = ""
      begin
        template_list = ses_client.list_templates({
          next_token: token,
          max_items: 10,
        })
        next_token = template_list.next_token
        index = 0
        while template_list.size > 0 && index < template_list.templates_metadata.count
            resp = ses_client.get_template({
              template_name: template_list.templates_metadata[index].name,
            })
            tmpl_hash = { 
              :id => index,
              :name => resp.template.template_name,
              :subject => resp.template.subject_part,
              :text_part => resp.template.text_part,
              :html_part => resp.template.html_part 
            }
            templates.push(tmpl_hash)
            index = index + 1
        end
      rescue Aws::SES::Errors::ServiceError => error
        logger.debug "CRONUS: DEBUG: Unable to fetch templates. Error message: #{error}"
      end

      return next_token, templates

    end

    # get all templates with next_token for every 10 items
    def get_all_templates

      templates = []
      next_token, templates = list_templates
      while next_token 
        next_token, templates_set = list_templates(next_token)
        templates += templates_set
      end

      return templates

    end

    # find a template with name or returns an empty template object
    def find_template(name)

      templates = get_all_templates
      template = new_template({})
      unless templates.empty?
        templates.each do |t|
          if t[:name] == name 
            template = new_template(t)
          end
        end
      end

      return template

    end

    def store_template(template)

      status = ""

      begin
        resp = ses_client.create_template({
          template: {
            template_name: template.name,
            subject_part: template.subject,
            text_part: template.text_part,
            html_part: template.html_part,
          },
        })
        audit_logger.info(current_user.id, 'has created a template ', template.name)
        msg = "Template #{template.name} is saved"
        status = "success"
      rescue Aws::SES::Errors::ServiceError => error
        status = "Unable to save template: #{error}"
        logger.debug "CRONUS: DEBUG: #{status} "
      end
      
      return status

    end

    def delete_template(template_name)

      status = ""

      begin
        resp = ses_client.delete_template({
            template_name: template_name,
        })
        audit_logger.info(current_user.id, 'has deleted template ', template_name)
        status = "success"
      rescue Aws::SES::Errors::ServiceError => error
        status = "Unable to delete template #{template_name}. Error message: #{error} "
        logger.debug status
      end

      return status
      
    end

    def update_template(name, subject, html_part, text_part)

      begin
        resp = ses_client.update_template({
          template: {
            template_name: name, 
            subject_part: subject,
            text_part: text_part,
            html_part: html_part,
          },
        })
        audit_logger.info(current_user.id, 'has updated template ', name)
        status = "success"
      rescue Aws::SES::Errors::ServiceError => error
        msg = "Unable to update template #{name}. Error: #{error}"
        status = msg
      end

     return status

    end

    # create a template instance used by find_template to return empty one
    def new_template(attributes = {})
      template = EmailService::Template.new(attributes)
    end

    def pretty_print_html(input)
      html_output = Nokogiri::HTML(input)
    end

    # 
    # verifications
    #

    # get verified identities collection for form rendering
    def get_verified_identities_collection(verified_identities, identity_type)

      verified_identities_collection = []
      if identity_type == "EmailAddress" && !verified_identities.empty?
        verified_identities.each do |element|
          verified_identities_collection << element[:identity] \
            unless element[:identity].include?('@activation.email.global.cloud.sap')
        end
      elsif identity_type == "Domain" && !verified_identities.empty?
        verified_identities.each do |element|
          verified_identities_collection << element[:identity]
        end    
      end

      return verified_identities_collection

    end

    
    # get identity verification status
    def get_identity_verification_status(identity, identity_type="EmailAddress")

      status = ""
      identities_list  = list_verified_identities(identity_type)
      identities_list.each do | identity_item |
        if identity_item[:identity] == identity
          case identity_item[:status]
            when "Success"
              status = "success"
            when "Pending"
              status = "pending"
              break
            when "Failed"
              status = "failed"
          end
        end
      end

      return status

    end

    #get a list of verified identities by status
    def get_verified_identities_by_status(identities, status)

      result = []
      identities.each do | item |
        if item[:status] == status
          result.push(item)
        end
      end

      return result

    end

    # find an identity by name
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

    # verify identities of the types EmailAddress and Domain
    def verify_identity(identity, identity_type)

      resp = Aws::SES::Types::VerifyDomainIdentityResponse.new 
      status = ""
      if identity.include?("sap.com") && identity_type == "EmailAddress"
        status = "sap.com domain email addresses are not allowed to verify as a sender(#{identity})"
      elsif identity == "" || !identity || identity == nil
        status = "#{identity_type} can't be empty"
      elsif identity != nil && identity_type == "Domain"
        begin
          resp = ses_client.verify_domain_identity({ domain: identity, })
          audit_logger.info(current_user.id, 'has initiated to verify domain identity ', identity)
        rescue Aws::SES::Errors::ServiceError => error
          resp = "#{identity_type} verification failed. Error message: #{error}"
        end
      elsif identity != nil && identity_type == "EmailAddress"
        begin
          ses_client.verify_email_identity({ email_address: identity, })
          audit_logger.info(current_user.id, 'has initiated to verify email identity ', identity)
          status = "success"
        rescue Aws::SES::Errors::ServiceError => error
          status = "#{identity_type} verification failed. Error message: #{error}"  
        end
      end

      return identity_type == "Domain" ? resp : status 

    end

    # list all verified identities
    def list_verified_identities(id_type)

      attrs = Hash.new
      verified_identities = []

      begin
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
          dkim_err, dkim_attr = get_dkim_attributes([identity])
          if dkim_attr
            dkim_enabled = dkim_attr[:dkim_attributes][identity][:dkim_enabled]
            dkim_tokens = dkim_attr[:dkim_attributes][identity][:dkim_tokens]
            dkim_verification_status = dkim_attr[:dkim_attributes][identity][:dkim_verification_status]
          end
          id += 1
          identity_hash = {id: id, identity: identity, status: status,\
           verification_token: token, dkim_enabled: dkim_enabled, \
           dkim_tokens: dkim_tokens, dkim_verification_status: dkim_verification_status }
          verified_identities.push(identity_hash)
        end
      rescue Aws::SES::Errors::ServiceError => error
        logger.debug "error while listing verified identities. Error message: #{error}"
      end

      return verified_identities

    end

    # delete a verified identity
    def remove_verified_identity(identity)

      status = ""
        begin
          ses_client.delete_identity({
            identity: identity
          })
          audit_logger.info(current_user.id, 'has removed verified identity ', identity)
          status = "success"
         rescue Aws::SES::Errors::ServiceError => error
          status = "error: #{error}"
          logger.debug "error while removing verified identity. Error message: #{error}"
        end

        return status 
    end

    # list dkim attributes
    def get_dkim_attributes(identities=[])

      err = ""
      dkim_attributes = {}

      begin
        dkim_attributes = ses_client.get_identity_dkim_attributes({
          identities: identities, 
        })
      rescue Aws::SES::Errors::ServiceError => error
        err = "#{error}"
        logger.debug "CRONUS: DEBUG: DKIM Attributes: #{error}"
      end

      return err, dkim_attributes

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
        resp = ses_client.verify_domain_dkim({
          domain: identity, 
        })
        audit_logger.info(current_user.id, ' has initiated DKIM verification ', identity)
        status = "success"
      rescue Aws::SES::Errors::ServiceError => error
        status = "#{error}"
        logger.debug "CRONUS: DEBUG: DKIM VERIFY: #{error}"
      end

      return status, resp

    end

    def enable_dkim(identity)

      status = ""

      begin
        resp = ses_client.set_identity_dkim_enabled({
          dkim_enabled: true, 
          identity: identity, 
        }) 
        audit_logger.info(current_user.id, ' has enabled DKIM ', identity)
        status = "success"
      rescue Aws::SES::Errors::ServiceError => error
        status = "#{error}"
        logger.debug "CRONUS: DEBUG: enable dkim: #{error}"
      end

      return status

    end
    
    def disable_dkim(identity)

      status = ""

      begin
        resp = ses_client.set_identity_dkim_enabled({
          dkim_enabled: false, 
          identity: identity, 
        }) 
        audit_logger.info(current_user.id, ' has disabled DKIM ', identity)
        status = "success"
      rescue Aws::SES::Errors::ServiceError => error
        status = "#{error}"
        logger.debug "CRONUS: DEBUG: DKIM Disable: #{error}"
      end

      return status

    end

    #

    # Get send data
    def get_send_data

      resp_hash = {}
      begin
        resp = ses_client.get_send_quota({})
      rescue Aws::SES::Errors::ServiceError => error
        logger.debug "CRONUS SEND : #{error}" 
      end
      resp_hash = resp ? resp.to_h : resp_hash

    end

    def get_send_stats
      stats_arr  = []
      begin
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

    #
    # Configsets
    # 

    def is_unique(name)
      configset = find_configset(name)
      return configset.name == name ? false : true
    end

    def store_configset(configset)

      begin
        resp = ses_client.create_configuration_set({
          configuration_set: {
            name: configset.name, 
          },
        })
        audit_logger.info(current_user.id, 'has created configset', configset.name)
        status = "success" 
      rescue Aws::SES::Errors::ServiceError => error
        status = "#{error}"
        logger.debug "CRONUS: DEBUG: store configset: #{error}"
      end

      return status

    end

    def delete_configset(name)

      begin
        resp = ses_client.delete_configuration_set({
              configuration_set_name: name,
        })
        audit_logger.info(current_user.id, 'has deleted configset', name)
        status = "success"
      rescue Aws::SES::Errors::ServiceError => error
        msg = "Unable to delete Configset #{name}. Error message: #{error} "
        status = msg
        logger.debug "CRONUS: DEBUG: DELETE CONFIGSET: #{error}"
      end

      return status

    end


    def list_configsets(token=nil)

      configset_hash = Hash.new
      configsets = []
      next_token = nil

      begin
        # lists 1000 items
        resp = ses_client.list_configuration_sets({
          next_token: token,
          max_items: 1000,
        })
        next_token = resp.next_token
        for index in 0 ... resp.configuration_sets.size
          configset_hash = { 
              :id => index,
              :name => resp.configuration_sets[index].name
            }
          configsets.push(configset_hash)
        end if resp.configuration_sets.size > 0
      rescue Aws::SES::Errors::ServiceError => error
        status = "#{error}"
        logger.debug "CRONUS: DEBUG: LIST CONFIGSETS: #{error}"
      end
      
      return next_token, configsets && !configsets.empty? ? configsets : error

    end

    # get an array of configset names
    def list_configset_names(token=nil)

      configset_names = []
      _, configsets = list_configsets(token)
      configsets.each do | cfg |
        configset_names << cfg[:name]
      end if configsets && !configsets.empty?
      configset_names     

    end

    # find existing config set
    def find_configset(name)

      _, configsets = list_configsets
      configset = new_configset({})
      configsets.each do |cfg|
        if cfg[:name] == name 
          configset = new_configset(cfg)
          return configset
        end
      end

    end

    # get details a configset
    def describe_configset(name)

      begin
        configset_description = ses_client.describe_configuration_set({
          configuration_set_name: name, # required
          configuration_set_attribute_names: ["eventDestinations"], # accepts eventDestinations, trackingOptions, deliveryOptions, reputationOptions
        })
      rescue Aws::SES::Errors::ServiceError => error
        status = "#{error}"
        logger.debug "CRONUS: DEBUG: DESCRIBE CONFIGSET: #{error}"
      end

      return configset_description

    end

    def matching_event_types_collection 
      ["send", "reject", "bounce", "complaint", "delivery", "open", "click", "renderingFailure"]
    end

    def dimension_value_source_collection
      ["messageTag", "emailHeader", "linkTag"]
    end

    def configuration_set_attribute_names
      ["eventDestinations", "trackingOptions", "deliveryOptions", "reputationOptions"]
    end

  end
end