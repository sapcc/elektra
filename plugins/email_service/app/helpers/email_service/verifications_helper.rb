module EmailService
  module VerificationsHelper
    include AwsSesHelper
    include PlainEmailHelper
    include TemplatedEmailHelper

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

    
    # Get identity verification status
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
      status
    end

    # To get a list of verified identities
    def get_verified_identities_by_status(all_identities, status)
      result = []
      all_identities.each do | item |
        if item[:status] == status
          result.push(item)
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
          audit_logger.info(current_user, 'has initiated to verify identity ', identity)
        rescue Aws::SES::Errors::ServiceError => error
          resp = "#{identity_type} verification failed. Error message: #{error}"
        end
      elsif identity != nil && identity_type == "EmailAddress"
        begin
          ses_client.verify_email_identity({ email_address: identity, })
          audit_logger.info(current_user, 'has initiated to verify email Address ', identity)
          status = "success"
        rescue Aws::SES::Errors::ServiceError => error
          status = "#{identity_type} verification failed. Error message: #{error}"  
        end
      end
      return identity_type == "Domain" ? resp : status 
    end

    # # Verify an email address with AWS SES excluding sap.com address
    # def verify_email(recipient)
    #   ses_client = create_ses_client
    #   if recipient != nil && ! recipient.include?("sap.com")
    #     begin
    #       ses_client.verify_email_identity({
    #       email_address: recipient
    #       })
    #       logger.debug "Verification email sent successfully to #{recipient}"
    #       flash.now[:success] = "Verification email sent successfully to #{recipient}"
    #     rescue Aws::SES::Errors::ServiceError => error
    #       logger.debug "Email verification failed. Error message: #{error}"
    #       flash.now[:warning] = "Email verification failed. Error message: #{error}"
    #     end

    #   end
    #   if recipient.include?("sap.com")
    #     flash.now[:warning] = "sap.com domain email addresses are not allowed to verify as a sender(#{recipient})"
    #     logger.debug "sap.com domain email addresses are not allowed to verify as a sender(#{recipient})"
    #   end
    # end

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
          dkim_err, dkim_attr = get_dkim_attributes([identity])
          # logger.debug "Status: #{status}"
          # logger.debug "dkim_attributes : #{dkim}"
          # logger.debug "dkim[:dkim_attributes] : #{dkim[:dkim_attributes]}"
          # logger.debug "dkim[:dkim_attributes][identity] : #{dkim[:dkim_attributes][identity]}"
          if dkim_attr
            dkim_enabled = dkim_attr[:dkim_attributes][identity][:dkim_enabled]
            dkim_tokens = dkim_attr[:dkim_attributes][identity][:dkim_tokens]
            dkim_verification_status = dkim_attr[:dkim_attributes][identity][:dkim_verification_status]
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
          audit_logger.info(current_user, 'has removed verified identity ', identity)
          status = "success"
         rescue Aws::SES::Errors::ServiceError => error
          status = "error: #{error}"
        end
        status 
    end

    # DKIM Related methods
    
    def get_dkim_attributes(identities=[])
      err = ""
      dkim_attributes = {}
      begin
        ses_client = create_ses_client
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
        ses_client = create_ses_client
        resp = ses_client.verify_domain_dkim({
          domain: identity, 
        })
        audit_logger.info(current_user, 'has initiated DKIM verification ', identity)
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
        audit_logger.info(current_user, 'has enabled DKIM ', identity)
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
        audit_logger.info(current_user, 'has disabled DKIM ', identity)
        status = "success"
      rescue Aws::SES::Errors::ServiceError => error
        status = "#{error}"
        logger.debug "CRONUS: DEBUG: DKIM Disable: #{error}"
      end
      return status
    end


    # create an array of valid email addresses
    def addr_validate(raw_addr)
      unless raw_addr.empty?
        values = raw_addr.split(",")
        addr = []
        values.each do |value|
          addr << value.strip
        end
        return addr
      end
      return []
    end

  end
end


