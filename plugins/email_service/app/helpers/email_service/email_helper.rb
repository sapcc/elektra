module EmailService
  module EmailHelper

    include AwsSesHelper

    class PlainEmail
      Email = Struct.new(:source, :to_addr, :cc_addr, :bcc_addr, :subject, :htmlbody, :textbody)
      attr_accessor :email
      def initialize(opts)
        @email = Email.new(opts[:source], opts[:to_addr], opts[:cc_addr], opts[:bcc_addr], opts[:subject], opts[:htmlbody], opts[:textbody] )
      end
    end

    class TemplatedEmail
      Email = Struct.new(:source, :to_addr, :cc_addr, :bcc_addr, :reply_to_addr, :template_name, :template_data, :configset_name)
      attr_accessor :email
      def initialize(opts)
        @email = Email.new(opts[:source], opts[:to_addr], opts[:cc_addr], opts[:bcc_addr], opts[:reply_to_addr], opts[:template_name], opts[:template_data], opts[:configset_name] )
      end
    end

    def new_email(attributes = {})
      email = PlainEmail.new(attributes)
    end

    def new_templated_email(attributes = {})
      email = TemplatedEmail.new(attributes)
    end

    def get_verified_email_collection(verified_emails)
      verified_email_collection = []
        verified_emails.each do |element|
          verified_email_collection << element[:email] unless element[:email].include?('@activation.email.global.cloud.sap')
        end unless verified_emails.empty? 
        verified_email_collection
    end

    # Get templates name as a collection to be rendered
    def get_templates_collection(templates)
      templates_collection = []
      if !templates.empty?
        templates.each do |template|
          templates_collection << template[:name]
        end
      end
      logger.debug "CRONUS DEBUG: templates_collection #{templates_collection} "
      templates_collection if !templates_collection.empty?
    end

    def isEmailVerified?(email)
      status = " "
      all_emails = list_verified_identities("EmailAddress")

      verified_emails = get_verified_emails_by_status(all_emails, "Success")
      pending_emails = get_verified_emails_by_status(all_emails, "Pending")

      all_emails.each do | e |
        if e[:email] == email
          case e[:status]
            when "Success"
              status = "success"
            when "Pending"
              status = "pending"
              break
            when "Failed"
              status = "failed"
          end
          logger.debug "CRONUS : status is assigned to : #{status}"
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
          # TO DO: check email addresses count is not exceeding 50 

        end
        return addr
      end
      return []
    end

    def email_to_array(plain_email)
      plain_email.email.to_addr= addr_validate(plain_email.email.to_addr)
      plain_email.email.cc_addr= addr_validate(plain_email.email.cc_addr)
      plain_email.email.bcc_addr = addr_validate(plain_email.email.bcc_addr)
      # return plain_email struct after validation
      plain_email
    end

  end
end


