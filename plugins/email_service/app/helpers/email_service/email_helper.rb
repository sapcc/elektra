module EmailService
  module EmailHelper
    include AwsSesHelper
    include PlainEmailHelper
    include TemplatedEmailHelper

    def new_email(attributes = {})
      email = PlainEmail.new(attributes)
    end

    def new_templated_email(attributes = {})
      email = TemplatedEmail.new(attributes)
    end


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

    # Get templates name as a collection to be rendered
    def get_templates_collection(templates)
      templates_collection = []
      if !templates.empty?
        templates.each do |template|
          templates_collection << template[:name]
        end
      end
      templates_collection
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

    def email_to_array(plain_email)
      plain_email.email.to_addr= addr_validate(plain_email.email.to_addr)
      plain_email.email.cc_addr= addr_validate(plain_email.email.cc_addr)
      plain_email.email.bcc_addr = addr_validate(plain_email.email.bcc_addr)
      plain_email
    end

  end
end


