module EmailService
  module ApplicationHelper

    def encoding
      @encoding ||= 'utf-8'
    end

    def user_id
      @user_id ||= current_user.id
    end

    def project_id
      @project_id ||= current_user.project_id
    end

    def service_url
      @service_url ||= current_user.service_url('email-aws')
    end

    def cronus_region
      @cronus_region ||= current_user.default_services_region
    end

    def ec2_creds
      @ec2_creds = services.identity.ec2_credentials(user_id, { tenant_id: project_id })&.first
    end

    def ec2_creds_collection
      @ec2_creds_collection ||= services.identity.ec2_credentials(user_id, { tenant_id: project_id })
    end

    def create_credentials
      @new_creds ||= services.identity.create_ec2_credentials(user_id, { tenant_id: project_id })
    end

    def find_credentials(access_id)
      @found ||= services.identity.find_ec2_credential(user_id, access_id)
    end

    def delete_credentials(access_id)
      services.identity.delete_ec2_credential(user_id, access_id)
    end

    def map_region(region)
  
      aws_region = 'eu-central-1'
      case region
      when 'na-us-1'
        aws_region = 'us-east-1'
      when 'na-us-2'
        aws_region = 'us-east-2'
      when 'na-us-3'
        aws_region = 'us-west-2'
      when 'ap-ae-1'
        aws_region = 'ap-south-1'
      when 'ap-jp-1'
        aws_region = 'ap-northeast-1'
      when 'ap-jp-2'
        aws_region = 'ap-northeast-2'
      when 'eu-de-1', 'qa-de-1', 'qa-de-2'
        aws_region = 'eu-central-1'
      when 'eu-nl-1'
        aws_region = 'eu-west-1'
      when 'na-ca-1'
        aws_region = 'ca-central-1'
      when 'la-br-1'
        aws_region = 'sa-east-1'
      else
        aws_region = 'eu-central-1'
      end

    end

    def account_env_collection
      return [ "PROD", "QA", "DEV", "DEMO", "TRAIN", "SANDBOX", "LAB" ]
    end

    def aws_mail_type_collection
      ["MARKETING", "TRANSACTIONAL"]
    end

    #
    # Raw email
    #

    # https://docs.aws.amazon.com/ses/latest/dg/mime-types.html
    def restricted_file_ext
      return([ '.ade','.adp','.app','.asp','.bas','.bat','.cer',
        '.chm','.cmd','.com','.cpl','.crt','.csh','.der','.exe','.fxp','.gadget','.hlp',
        '.hta','.inf','.ins','.isp','.its','.js','.jse','.ksh','.lib','.lnk','.mad',
        '.maf','.mag','.mam','.maq','.mar','.mas','.mat','.mau','.mav','.maw','.mda',
        '.mdb','.mde','.mdt','.mdw','.mdz','.msc','.msh','.msh1','.msh2','.mshxml',
        '.msh1xml','.msh2xml','.msi','.msp','.mst','.ops','.pcd','.pif','.plg','.prf',
        '.prg','.reg','.scf','.scr','.sct','.shb','.shs','.sys','.ps1','.ps1xml','.ps2',
        '.ps2xml','.psc1','.psc2','.tmp','.url','.vb','.vbe','.vbs','.vps','.vsmacros',
        '.vss','.vst','.vsw','.vxd','.ws','.wsc','.wsf','.wsh','.xnk'
        ])
    end

    # need to keep for a while for backward compatibility
    def ses_client

      @region ||= map_region(@cronus_region)
      @endpoint ||= service_url

      unless !ec2_creds || ec2_creds.nil?
        begin
          @credentials ||= Aws::Credentials.new(ec2_creds.access, ec2_creds.secret)
          @ses_client ||= Aws::SES::Client.new(region: @region, endpoint: @endpoint, credentials: @credentials)
        rescue Aws::SES::Errors::ServiceError => e
          Rails.logger.error e.message
          return e.message
        rescue StandardError => e
          Rails.logger.error e.message
          return e.message
        end
      end

      @ses_client ? @ses_client : nil

    end

    def ses_client_v2

      @region ||= map_region(@cronus_region)
      @endpoint ||= service_url

      unless !ec2_creds || ec2_creds.nil?
        begin
          @credentials ||= Aws::Credentials.new(ec2_creds.access, ec2_creds.secret)
          @ses_client_v2 ||= Aws::SESV2::Client.new(region: @region, endpoint: @endpoint, credentials: @credentials)
        rescue Aws::SESV2::Errors::ServiceError => e
          Rails.logger.error e.message
          return "\n [email_service][application_helper][ses_client_v2][:error] #{e.message}  \n" 
        end
      end

      @ses_client_v2 ? @ses_client_v2 : nil

    end

    # Get Account Details

    def get_account
      
      if nebula_active? &&  ec2_creds && ses_client_v2
        @account ||= ses_client_v2.get_account(params = {})
      end
      return @account

    end

    # Get metrics data
    def batch_get_metric_data(identity, start_date=Time.now-86400, end_date=Time.now)

      begin
        resp = ses_client_v2.batch_get_metric_data({
          queries: [ # required
            {
              id: "QueryIdentifier", # required
              namespace: "VDM", # required, accepts VDM
              metric: "SEND", # required, accepts SEND, COMPLAINT, PERMANENT_BOUNCE, TRANSIENT_BOUNCE, OPEN, CLICK, DELIVERY, DELIVERY_OPEN, DELIVERY_CLICK, DELIVERY_COMPLAINT
              dimensions: {
                "EMAIL_IDENTITY" => identity, # "MetricDimensionValue",
              },
              start_date: start_date, # Time.now, # required
              end_date: end_date, # Time.now, # required
            },
          ],
        })
        audit_logger.info(current_user.id, ' has fetched metric data ')
        Rails.logger.debug "\n #{current_user.id} has fetched metric data  \n"
      rescue Aws::SESV2::Errors::ServiceError => e
        error = "[email_service][application_helper][batch_get_metric_data] #{e.message}"
        Rails.logger.error "\n #{error} \n"
      rescue Exception => e
        error = "[email_service][application_helper][batch_get_metric_data] #{e.message}"
        Rails.logger.error "\n #{error} \n"
      end

      return error ? error : resp
    end

    def list_email_identities(nextToken="", page_size=1000)
      id=0
      identities = []
      identity = {}
      if nebula_active? &&  ec2_creds && ses_client_v2
        
        resp = ses_client_v2.list_email_identities({
            next_token: nextToken,
            page_size: page_size,
        })
        # Adding ID to each element
        resp.email_identities.each do |item|
          identity = { id: id, identity_type: item.identity_type, identity_name: item.identity_name, sending_enabled: item.sending_enabled, verification_status: item.verification_status }
          id+=1
          unless item.identity_name.include?("@activation.email.global.cloud.sap")
            details = ses_client_v2.get_email_identity({
              email_identity: item.identity_name, # required
            })
            
            identity.merge!({
              # dkim_type: dkim_type, # constructed based on dkim_attributes
              feedback_forwarding_status: details.feedback_forwarding_status,  #=> Boolean
              verified_for_sending_status: details.verified_for_sending_status, #=> Boolean
              dkim_attributes: details.dkim_attributes, #=> Boolean
              mail_from_attributes: details.mail_from_attributes.mail_from_domain, #=> String
              policies: details.policies, #=> Hash
              tags: details.tags, #=> Array
              configuration_set_name: details.configuration_set_name #=> String
            })
            if details.dkim_attributes.next_signing_key_length.nil?
              identity.merge!({dkim_type: 'byo_dkim' })
            else
              identity.merge!({dkim_type: 'easy_dkim' })
            end
          end
          identities.push identity
        end
      end
      
      return identities
    end

    def email_addresses

      @email_addresses ||= list_email_identities
      identities = []
      if @email_addresses
        @email_addresses.each do |item|
          if item[:identity_type] == "EMAIL_ADDRESS" && !item[:identity_name].include?("@activation.email.global.cloud.sap")
            identities.push item
          end
        end
      end
      return identities

    end

    def email_addresses_collection

      @email_addresses ||= email_addresses
      identities_collection = []
      if @email_addresses
        @email_addresses.each do |item|
          if item[:identity_type] == "EMAIL_ADDRESS"
            identities_collection.push item[:identity_name]
          end
        end
      end
      return identities_collection

    end

    def domains

      @domains ||= list_email_identities
      identities = []
      if @domains
        @domains.each do |item|
          if item[:identity_type] == "DOMAIN"
            identities.push item
          end
        end
      end
      return identities

    end

    def domains_collection

      @domains ||= domains
      domains_collection = []
      if @domains
        @domains.each do |item|
          domains_collection.push item[:identity_name]
        end
      end
      return domains_collection

    end


    def managed_domains

      @domains ||= list_email_identities
      identities = []
      if @domains
        @domains.each do |item|
          if item[:identity_type] == "MANAGED_DOMAIN"
            identities.push item
          end
        end
      end
      return identities

    end

    # find an identity by name
    def find_verified_identity_by_name(identity, id_type="EMAIL_ADDRESS")

      if id_type == "EMAIL_ADDRESS"
        @id_list ||= email_addresses
      elsif id_type == "DOMAIN"
        @id_list ||= domains
      elsif id_type == "MANAGED_DOMAIN"
        @id_list ||= managed_domains
      else
        @id_list = []
      end

      found = {}
      unless @id_list.empty?
        @id_list.each do |item|
          if identity == item[:identity_name]
              found = item
          end
        end
      end

      return found

    end

    def send_data
      @send_data ||= get_account.send_quota
    end

    # v3 Conversion
    def create_email_identity_email(verified_email, tags=[{ key: "Tagkey", value: "TagValue"}], configset_name=nil)
      
      begin
        resp = ses_client_v2.create_email_identity({
          email_identity: verified_email, # "Identity", # required
          tags: tags, # Array of Hashes
          configuration_set_name: configset_name, # String
        })
        audit_logger.info(current_user.id, 'has added an email identity (type: email) ', verified_email)
        status = "success"
      rescue Aws::SESV2::Errors::ServiceError => e
        Rails.logger.error e.message
        flash[:error] = "[create_email_identity_email] : Status Code:(#{e.code}): #{e.message} "
        status = e.message
      rescue Exception => e
        flash[:error] = "[create_email_identity_email] : Status Code:[500]: #{e.message} "
        status = e.message
      end
      return status
    end

    def delete_email_identity(identity)
      
      status = nil
      begin
        resp = ses_client_v2.delete_email_identity({
          email_identity: identity,
        })
        audit_logger.info(current_user.id, ' has removed verified identity ', identity)
        
        status = "success"
      rescue Aws::SESV2::Errors::ServiceError => e
        status = "[email_service][application_helper][delete_email_identity] #{e.message}"
        Rails.logger.error "\n #{status} \n"
      rescue Exception => e
        status = "[email_service][application_helper][delete_email_identity] #{e.message}"
        Rails.logger.error "\n #{status} \n"
      end
      return status

    end

    def create_email_identity_domain(verified_domain)
      
      dkim_signing_attributes = {}

      if verified_domain.dkim_type == 'easy_dkim'
        dkim_signing_attributes.merge!({
          next_signing_key_length: verified_domain.next_signing_key_length,
        })
      elsif verified_domain.dkim_type == 'byo_dkim'
        dkim_signing_attributes.merge!({
          domain_signing_selector: verified_domain.domain_signing_selector,
          domain_signing_private_key: verified_domain.domain_signing_private_key,
        })
      end

      email_identity_attributes = {
        email_identity: verified_domain.identity_name, 
        tags: verified_domain.tags,
        dkim_signing_attributes: dkim_signing_attributes,
      }

      unless verified_domain.configuration_set_name.nil? 
        email_identity_attributes.merge!({
          configuration_set_name: verified_domain.configuration_set_name,
        })
      end

      status = nil

      begin
        resp = ses_client_v2.create_email_identity(email_identity_attributes)
        audit_logger.info(current_user.id, 'has added an email identity (type: domain) ', verified_domain.identity_name)
        status = "success"
      rescue Aws::SESV2::Errors::ServiceError => e
        status = "[email_service][application_helper][create_email_identity_domain][error]: #{e.message}"
        Rails.logger.error "\n #{status}"
      rescue Exception => e
        status = "[email_service][application_helper][create_email_identity_domain][error]: #{e.message}"
        Rails.logger.error "\n #{status}"
      end

      return status

    end

    def find_identity_name(identity)

      @verified_domains = domains
      @verified_domain = new_verified_domain({})
      unless @verified_domains.empty?
        @verified_domains.each do |v|
          if v[:identity_name] == identity
            @verified_domain = new_verified_domain(v)
          end
        end
      end

      return @verified_domain

    end

    def new_verified_domain(attributes = {})
      verified_domain = EmailService::VerifiedDomain.new(attributes)
    end

    # TO_DO
    def domain_statistics_report(identity, report_start_date=Time.now-86400, report_end_date=Time.now)
      begin 
        @domain_statistics_report = ses_client_v2.get_domain_statistics_report({
          domain: identity, # required
          start_date: report_start_date, # required
          end_date: report_end_date, # required
        })
      rescue AWS::SESV2::Errors::ServiceError => e
        @error = "\n[domain_statistics_report][error]: #{e.message} \n"
        Rails.logger.error @resp
      end

    end

    def list_contact_lists(next_token="", page_size=1)

      begin
        @resp = ses_client_v2.list_contact_lists({
          page_size: page_size,
          next_token: next_token,
        })
      rescue AWS::SESV2::Errors::ServiceError => e
        @resp = "Listing contact lists failed. Error message: #{e.message}"
        Rails.logger.error @resp
      end

    end

    def send_stats
      @send_stats ||= domain_statistics_report
    end



    # DKIM Attributes

    def put_email_identity_dkim_signing_attributes(email_identity, signing_attributes_origin="AWS", signing_attributes={})
      resp = ses_client_v2.put_email_identity_dkim_signing_attributes({
        email_identity: "Identity", # required
        signing_attributes_origin: "AWS_SES", # required, accepts AWS_SES, EXTERNAL
        signing_attributes: {
          domain_signing_selector: "Selector",
          domain_signing_private_key: "PrivateKey",
          next_signing_key_length: "RSA_1024_BIT", # accepts RSA_1024_BIT, RSA_2048_BIT
        },
      })
    end

    def put_email_identity_configuration_set_attributes(email_identity, configuration_set_name)
      begin
        resp = ses_client_v2.put_email_identity_configuration_set_attributes({
          email_identity: "Identity", # required
          configuration_set_name: "ConfigurationSetName",
        })
      rescue AWS::SESV2::Errors::ServiceError => e
        err = "#{e.message}"
        Rails.logger.error "[put_email_identity_configuration_set_attributes]: ERROR : #{err}"
      rescue Exception => e
        status = "[put_email_identity_configuration_set_attributes] : exception : #{e.message}"
        Rails.logger.error " [put_email_identity_configuration_set_attributes] : Status Code:[500] #{e.message}"
      end
    end

    # list dkim attributes
    def get_dkim_attributes(identity)

      begin
        found = {}
        @domains ||= domains
        if @domains
          @domains.each do |item|
            if item[:identity_name] == identity
              found = item
            end
          end
        end
        
      rescue AWS::SESV2::Errors::ServiceError => e
        Rails.logger.error "[get_dkim_attributes]: ERROR : #{e.message}"
      rescue Exception => e
        Rails.logger.error " [get_dkim_attributes] : ERROR : Status Code:[500] #{e.message}"
      end

      return found.empty? ? nil : found

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

    def start_dkim_verification(identity)

      status = nil

      begin
          resp = ses_client.verify_domain_dkim({
          domain: identity,
          })
          audit_logger.info(current_user.id, ' has initiated DKIM verification ', identity)
          status = "success"
      rescue Aws::SES::Errors::ServiceError => e
          status = "#{e.message}"
          Rails.logger.error " DKIM VERIFY: #{e.message}"
      end

      return status, resp

    end

    def enable_dkim(identity)

      status = nil

      begin
          resp = ses_client.set_identity_dkim_enabled({
          dkim_enabled: true,
          identity: identity,
          })
          audit_logger.info(current_user.id, ' has enabled DKIM ', identity)
          status = "success"
      rescue Aws::SES::Errors::ServiceError => e
          status = "#{e.message}"
          Rails.logger.error " enable dkim: #{e.message}"
      end

      return status

    end

    def disable_dkim(identity)

      status = nil

      begin
          resp = ses_client.set_identity_dkim_enabled({
          dkim_enabled: false,
          identity: identity,
          })
          audit_logger.info(current_user.id, ' has disabled DKIM ', identity)
          status = "success"
      rescue Aws::SES::Errors::ServiceError => e
          status = "#{e.message}"
          Rails.logger.error " DKIM Disable: #{e.message}"
      end

      return status

    end


    def configsets
      @configsets ||= list_configsets
    end

    def configset_names
      @configset_names ||= list_configset_names
    end

    #
    # PlainEmail
    #

    # send plain email
    def send_plain_email(plain_email)

      begin
        resp = ses_client_v2.send_email({
          from_email_address: plain_email.source,
          destination: {
            to_addresses: plain_email.to_addr,
            cc_addresses: plain_email.cc_addr,
            bcc_addresses: plain_email.bcc_addr,
          },
          reply_to_addresses: plain_email.reply_to_addr,
          feedback_forwarding_email_address: plain_email.return_path,
          content: {
            simple: {
              subject: {
                data: plain_email.subject,
                charset: @encoding,
              },
              body: {
                text: {
                  data: plain_email.text_body,
                  charset: @encoding,
                },
                html: {
                  data: plain_email.html_body,
                  charset: @encoding,
                },
              },
            },
          },
          email_tags: [
            {
              name: "sample_tag_name", # required
              value: "sample_tag_value", # required
            }
          ],
          # configuration_set_name: "ConfigurationSetName",
          # list_management_options: {
          #   contact_list_name: "ContactListName", # required
          #   topic_name: "TopicName",
          # },
        })
        status = "success - email sent to #{plain_email.to_addr} "
        audit_logger.info("[cronus][send_plain_email] : ", current_user.id, 'has sent email to', "#{status}")
      rescue Aws::SESV2::Errors::ServiceError => e
        status = e.message
        Rails.logger.error "[cronus][send_plain_email][Aws::SESV2::Errors::ServiceError] : sending plain email  #{e.message}"
      rescue StandardError => e
        status = e.message
        Rails.logger.error "[cronus][send_plain_email][StandardError] : sending plain email  #{e.message}"
      end
      Rails.logger.error "[cronus][send_plain_email] : RETURNING #{status} to controller"
      return status

    end

    # switch between email and domain source type

    def selected_source_type(type)
      if type.blank?
        'email'
      else
        type.downcase
      end
    end

    def hide_email_source(type)
      if type.blank?
        return true
      else
        return false if type.casecmp('email').zero?
      end
      false
      #true
    end

    def hide_domain_source(type)
      if type.blank?
        return true
      else
        return false if type.casecmp('domain').zero?
      end

      true
    end


    # switch between EASYDKIM and BYODKIM
    def selected_dkim_type(type)
      if type.blank?
        'easy_dkim'
      else
        type.downcase
      end
    end

    def hide_easy_dkim(type)
      if type.blank?
        return true
      else
        return false if type.casecmp('easy_dkim').zero?
      end
      false
    end

    def hide_byo_dkim(type)
      if type.blank?
        return true
      else
        return false if type.casecmp('byo_dkim').zero?
      end

      true
    end


    #
    # TemplatedEmail
    #

    # send a templated email
    def send_templated_email(templated_email)

      destination = { to_addresses: templated_email.to_addr, }

      unless templated_email.cc_addr.nil? 
        destination = destination.merge!({cc_addresses: templated_email.cc_addr,})
      end

      unless templated_email.bcc_addr.nil? 
        destination = destination.merge!({cc_addresses: templated_email.bcc_addr,})
      end

      send_email_hash = {
        from_email_address: templated_email.source,
        destination: destination,
      }

      unless templated_email.configset_name.nil?
        send_email_hash.merge!({
          configuration_set_name: templated_email.configset_name,
        })
      end

      unless templated_email.list_management_options.nil?
        send_email_hash.merge!({
          list_management_options: {
            contact_list_name: templated_email.list_management_options.contact_list_name,# "ContactListName", # required
            topic_name: templated_email.list_management_options.topic_name,
          },
        })
      end

      unless templated_email.reply_to_addr.nil? 
        send_email_hash.merge!({
          reply_to_addresses: templated_email.reply_to_addr,
        })
      end

      unless templated_email.return_path.nil? 
        send_email_hash.merge!({
          feedback_forwarding_email_address: templated_email.return_path,
        })
      end

      if templated_email.tags.empty? 
        send_email_hash.merge!({
          email_tags: [
            {
              name: "sample_tag_name", # required
              value: "sample_tag_value", # required
            }
          ],
        })
      end

      send_email_hash.merge!({
        content: {
          template: {
            template_name: templated_email.template_name,
            template_data: templated_email.template_data,
          },
        },
      })
      

      begin
        resp = ses_client_v2.send_email(send_email_hash)
        
        status = "success - email sent to #{templated_email.to_addr} ,#{templated_email.cc_addr}, #{templated_email.bcc_addr}"
        audit_logger.info(current_user.id, 'has sent templated email from the template', \
          templated_email.template_name,  'to', templated_email.to_addr, \
          templated_email.cc_addr, templated_email.bcc_addr, 'with the template data', templated_email.template_data )
        
      rescue Aws::SESV2::Errors::ServiceError => e
        error = e.message
        Rails.logger.error "\n[cronus][send_templated_email][ServiceError] : sending templated email  #{e.message}\n"
      rescue StandardError => e
        Rails.logger.error "\n[cronus][send_templated_email][StandardError] : sending templated email  #{e.message}\n"
        error = e.message
      end
      
      return resp && resp.successful? ? "success" : error

    end

    #
    # Templates
    #

    def templates
      @templates ||= get_all_templates
    end

    def templates_collection
      unless !templates && templates.empty?
        @templates_collection ||= get_templates_collection(templates)
      else
        []
      end
    end


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
      unless templates.empty?
        templates.each do |template|
          templates_collection << template[:name]
        end
      end
      templates_collection
    end

    # get all templates with next_token for every 10 items
    def get_all_templates

      templates = []
      next_token, templates = list_templates
      while !next_token.nil?
        next_token, templates_set = list_templates(next_token)
        templates += templates_set
      end

      return templates

    end

    # list first 10 templates
    def list_templates(token=nil)
      tmpl_hash = Hash.new
      templates = []
      next_token = nil
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
      rescue Aws::SES::Errors::ServiceError => e
        Rails.logger.error " Unable to fetch templates. Error message: #{e.message}"
      end

      return next_token, templates

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

      status = nil

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
      rescue Aws::SES::Errors::ServiceError => e
        status = "Unable to save template: #{e.message}"
        Rails.logger.error " #{status}."
      end

      return status

    end

    def delete_template(template_name)

      status = nil

      begin
        resp = ses_client.delete_template({
            template_name: template_name,
        })
        audit_logger.info(current_user.id, 'has deleted template ', template_name)
        status = "success"
      rescue Aws::SES::Errors::ServiceError => e
        status = e.message
        Rails.logger.error "Unable to delete template #{template_name}. Error message: #{e.message} "
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
      rescue Aws::SES::Errors::ServiceError => e
        msg = "Unable to update template #{name}. Error: #{e.message}"
        Rails.logger.error msg
        status = msg
      end

     return status

    end

    def new_template(attributes = {})
      template = EmailService::Template.new(attributes)
    end

    def pretty_print_html(input)
      html_output = Nokogiri::HTML(input)
    end

    def toggle_dkim(identity, dkim_enabled=true)

      status = nil

      begin
        resp = ses_client_v2.put_email_identity_dkim_attributes({
          email_identity: identity, # required
          signing_enabled: dkim_enabled,
        })
        audit_logger.info(current_user.id, ' has toggled DKIM for [', identity, '] to : ', dkim_enabled)
        status = "success"
      rescue AWS::SESV2::Errors::ServiceError => e
        status = "#{e.message}"
        Rails.logger.error " enable dkim: #{e.message}"
      end

      return status

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
        resp = ses_client_v2.create_configuration_set({
          configuration_set_name: configset.name,
          tracking_options: {
            custom_redirect_domain: configset.custom_redirect_domain,
          },
          delivery_options: {
            tls_policy: configset.tls_policy,
            sending_pool_name: configset.sending_pool_name,
          },
          reputation_options: {
            reputation_metrics_enabled: configset.reputation_metrics_enabled,
            last_fresh_start: configset.last_fresh_start,
          },
          sending_options: {
            sending_enabled: configset.sending_enabled,
          },
          tags: configset.tags,
          suppression_options: {
            suppressed_reasons: configset.suppressed_reasons,
          },
        })
        audit_logger.info(current_user.id, 'has created configset with following values ', configset.inspect)
        status = "success"
      rescue AWS::SESV2::Errors::ServiceError => e
        status = "#{e.message}"
        Rails.logger.error " store configset (v2): #{e.message}"
      end

      return status

    end

    def delete_configset(name)

      begin
        resp = ses_client_v2.delete_configuration_set({
              configuration_set_name: name,
        })
        audit_logger.info(current_user.id, 'has deleted configset', name)
        status = "success"
      rescue AWS::SESV2::Errors::ServiceError => e
        msg = "Unable to delete Configset #{name}. Error message: #{e.message} "
        status = msg
        Rails.logger.error msg
      end

      return status

    end

    def list_configsets(token=nil, page_size=1000)

      configset_hash = Hash.new
      configsets = []
      next_token = nil
      begin
        # lists 1000 items by default
        resp = ses_client_v2.list_configuration_sets({
          next_token: token,
          page_size: page_size
        })

        next_token = resp.next_token
        if resp.configuration_sets.size > 0
          for index in 0 ... resp.configuration_sets.size
            
            item = ses_client_v2.get_configuration_set({
              configuration_set_name: resp.configuration_sets[index],
            })
            
            configset_hash = {
                :id => index,
                :name => item.configuration_set_name,
                :tracking_options => item.tracking_options,
                :delivery_options => item.delivery_options,
                :reputation_options => item.reputation_options.reputation_metrics_enabled,
                :sending_options => item.reputation_options,
                :tags => item.tags,
                :suppression_options => item.suppression_options,
              }
            configsets.push(configset_hash)
          end
        else
          status = "#{I18n.t('email_service.errors.configset_list_empty')}"
          Rails.logger.debug status
        end
      rescue AWS::SESV2::Errors::ServiceError => e
        error = "#{I18n.t('email_service.errors.configset_list_error')} :  #{e.message}"
        Rails.logger.error error
      end
      return configsets
    end

    # get an array of configset names up to 1000 entries
    def list_configset_names(token="")

      configset_names = []
      configsets = list_configsets(token)
      
      unless configsets.empty?
        configsets.each do | cfg |
          configset_names << cfg[:name]
        end
      end

      return configset_names

    end

    def new_configset(attributes = {})
      return ::EmailService::Configset.new(attributes)
    end

    def find_configset(name)
      
      configsets = list_configsets
      configset = new_configset({})
      unless configsets.empty?
        configsets.each do |cfg|
          if cfg[:name] == name
            configset = new_configset(cfg)
            return configset
          end
        end
      end

    end

    def clone_receipt_rule_set # return empty response.
      resp = ses_client.clone_receipt_rule_set({
        rule_set_name: "ReceiptRuleSetName", # required
        original_rule_set_name: "ReceiptRuleSetName", # required
      })
    end

    def create_configuration_set_event_destination(params = {})

      resp = ses_client.create_configuration_set_event_destination({
        configuration_set_name: "ConfigurationSetName", # required
        event_destination: { # required
          name: "EventDestinationName", # required
          enabled: false,
          matching_event_types: ["send"], # required, accepts send, reject, bounce, complaint, delivery, open, click, renderingFailure
          kinesis_firehose_destination: {
            iam_role_arn: "AmazonResourceName", # required
            delivery_stream_arn: "AmazonResourceName", # required
          },
          cloud_watch_destination: {
            dimension_configurations: [ # required
              {
                dimension_name: "DimensionName", # required
                dimension_value_source: "messageTag", # required, accepts messageTag, emailHeader, linkTag
                default_dimension_value: "DefaultDimensionValue", # required
              },
            ],
          },
          sns_destination: {
            topic_arn: "AmazonResourceName", # required
          },
        },
      })

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


    #

    ### Custom verification email template

    #

    def create_custom_verification_email_template(custom_template)

      begin

        resp = ses_client.create_custom_verification_email_template({
          template_name: custom_template.template_name, #params[:template_name],
          from_email_address:  custom_template.from_email_address, #params[:from_email_address],
          template_subject: custom_template.template_subject, # params[:template_subject],
          template_content: custom_template.template_content, # params[:template_content],
          success_redirection_url: custom_template.success_redirection_url, #params[:success_redirection_url],
          failure_redirection_url: custom_template.failure_redirection_url, #params[:failure_redirection_url],
        })
        status = "success"
      rescue Aws::SES::Errors::ServiceError => e
        status = "#{e.message}"
        Rails.logger.error "Create custom verification template failed: #{e.message}"
      end
      return status
    end

    def delete_custom_verification_email_template(name)

      begin
        resp = ses_client.delete_custom_verification_email_template({
          template_name: name,
        })
        return "success"
      rescue Aws::SES::Errors::ServiceError => e
        status = "#{e.message}"
        Rails.logger.error "Delete custom verification template: #{e.message}"
      end

    end

    
    def new_custom_verification_email_template(attributes = {})
      template = EmailService::CustomVerificationEmailTemplate.new(attributes)
    end

    def update_custom_verification_email_template(custom_template = {})
      begin
        resp = ses_client.update_custom_verification_email_template({
          template_name: custom_template.template_name,
          from_email_address: custom_template.from_email_address,
          template_subject: custom_template.template_subject,
          template_content: custom_template.template_content,
          success_redirection_url: custom_template.success_redirection_url,
          failure_redirection_url: custom_template.failure_redirection_url,
        })
        return "success"
      rescue Aws::SES::Errors::ServiceError => e
        status = "#{e.message}"
        Rails.logger.error "Create custom verification template: #{e.message}"
      end

    end

    def custom_templates(next_token = nil)

      @custom_verification_email_templates = []

      resp = list_custom_verification_email_templates({
        next_token: next_token,
        max_results: 50,
      })

      if resp.is_a?(Error)
        return resp
      end

      index = 1
      resp[:custom_verification_email_templates].each do  |item|
        template_item = {
          :id => index,
          :template_name => item[:template_name],
          :from_email_address => item[:from_email_address],
          :template_subject => item[:template_subject],
          :success_redirection_url => item[:success_redirection_url],
          :failure_redirection_url => item[:failure_redirection_url],
        }
      @custom_verification_email_templates.push(template_item)
      index += 1
      end
      return @custom_verification_email_templates

    end

    def list_custom_verification_email_templates(params = {})
      begin
        @all_templates ||= ses_client.list_custom_verification_email_templates(params)
      rescue Aws::SES::Errors::ServiceError => e
        status = "#{e.message}"
        Rails.logger.error " Create custom verification template: #{status}"
        return e
      end
    end

    # find a template with name or returns an empty template object
    def find_custom_verification_email_template(name)

      begin
        template = ses_client.get_custom_verification_email_template({
          template_name: name, # required
        })
      rescue Aws::SES::Errors::ServiceError => e
        status = "#{e.message}"
        Rails.logger.error " Create custom verification template: #{status}"
      end

      return template ? template : new_custom_verification_email_template

    end

    #
    ### nebula
    
    def custom_endpoint_url
      return nil
    end

    def nebula_provider_collection
      ["aws", "int"]
    end

    def nebula_endpoint_url
      @nebula_endpoint = current_user.service_url('nebula')
    end

    def _nebula_request(uri, method, headers = nil, body = nil )

      # TODO Replace with Elektron Calls.
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      request = Net::HTTP::Get.new(uri)
      case method
      when "GET"
        request = Net::HTTP::Get.new(uri)
      when "POST"
        request = Net::HTTP::Post.new(uri)
      when "DELETE"
        request = Net::HTTP::Delete.new(uri)
      else
        request = Net::HTTP::Get.new(uri)
      end
      request["X-Auth-Token"] = current_user.token
      request["Content-Type"] = "application/json"
      unless headers.nil?
        JSON.parse(headers).each do |name, value|
          request[name] = value
        end
      end

      unless body.nil?
        request.body = body
      end

      begin
        response = https.request(request)
        JSON.parse(response.read_body)
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
             Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
        Rails.logger.error e.message
        return e.message
      end
      return response

    end

    def nebula_details
      
      url = URI("#{nebula_endpoint_url}/v1/aws/#{project_id}")
      headers =  nil # JSON.dump({ "sample-head1": "head1", "sample-head2": "head2" })
      body = nil # JSON.dump({ "sample-body2": "body1", "sample-body2": "body2", })

      # TODO replace _nebula_request with Elektron API Calls
      response = _nebula_request(url, "GET", headers, body)

      begin
        status = JSON.parse(response.read_body)
      rescue JSON::ParserError => e
        status = "{\"error\" => \"#{e.message}\"}"
      end
      return status

    end

    def nebula_status
      
      if nebula_details
        if nebula_details.is_a?(Hash)
          if nebula_details.has_key?("status")
            status = nebula_details["status"]
          elsif nebula_details.has_key?("compliant") && nebula_details.has_key?("security_attributes")
            status = "REQUESTED"
          else
            status = "INACTIVE"
          end
        elsif nebula_details.is_a?(String)
          return JSON.parse(nebula_details).has_key?("error") ? "ERROR" : "" rescue nil
        end
      end
      
      return status ? status : nil

    end

    def nebula_active?
      @nebula_active ||= nebula_details && nebula_details["status"] == "GRANTED" ? true : false
    end

    def get_nebula_uri(provider = nil, custom_url = nil)

      unless custom_url == nil
        @nebula_url ||= URI("#{custom_url}/v1/#{provider}/#{project_id}")
      else
        provider = "aws" unless provider
        @nebula_url ||= URI("https://nebula.#{cronus_region}.cloud.sap/v1/#{provider}/#{project_id}")
      end
    end

    def nebula_activate(multicloud_account = nil)
      return "nebula details are invalid " if multicloud_account.nil?
      provider = multicloud_account.provider || "aws"
      endpoint_url = multicloud_account.custom_endpoint_url ? multicloud_account.custom_endpoint_url : nil
      url = get_nebula_uri(provider, endpoint_url)

      body = JSON.dump({
        "accountEnv": multicloud_account.account_env,
        "identities": multicloud_account.identity, # array
        "mailType": multicloud_account.mail_type || "TRANSACTIONAL",
        "securityOfficer": multicloud_account.security_officer
      })
      response = _nebula_request(url, "POST", headers, body)

      if response.code.to_i < 300
        status = "success"
      else
        status ="#{response.code} : #{response.read_body}"
      end
      return status

    end

    def nebula_available?
      return services.available?(:nebula)
    end

    def nebula_deactivate(multicloud_account = nil)
      
      url = get_nebula_uri("aws", custom_endpoint_url)
      response = _nebula_request(url, "DELETE", nil, nil)
      if response.code.to_i < 300
        status = "success"
      else
        status ="#{response.code} : #{response.read_body}"
      end
      return status
      
    end

 end
end
