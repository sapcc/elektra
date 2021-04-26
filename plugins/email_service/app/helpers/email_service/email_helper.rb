module EmailService
  module EmailHelper

    include AwsSesHelper

    class PlainEmail
      Email = Struct.new(:encoding, :source, :to_addr, :cc_addr, :bcc_addr, :subject, :htmlbody, :textbody)
      attr_accessor :email
      def initialize(opts)
        @email = Email.new(opts[:encoding], opts[:source], opts[:to_addr], opts[:cc_addr], opts[:bcc_addr], opts[:subject], opts[:htmlbody], opts[:textbody] )
      end
    end

    def new_email(attributes = {})
      email = PlainEmail.new(attributes)
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

    def addr_validate(raw_addr)
      unless raw_addr.empty?
        values = raw_addr.split(",")
        addr = []
        values.each do |value|
          addr << value.strip
          # TO DO: check email addresses count is not exceeding 50 
          # @email_addr_count =  @email_addr_count + 1
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


