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
      verified_emails, pending_emails = list_verified_emails
        verified_emails.each do | e |
          if e[:email] == email
            status = "success"
            logger.debug "status is assigned to : #{status}"
            break
          end
        end

        pending_emails.each do | e |
          if e[:email] == email
            status = "pending"
            logger.debug "status is assigned to : #{status}"
            break
          end
        end
        logger.debug "return status is : #{status}"
       status
    end



  end
end


