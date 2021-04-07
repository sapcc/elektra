# require 'logger'
module EmailService
  module AwsSesHelper

    # class PlainEmail
    #   Email = Struct.new(:encoding, :source, :to_addr, :cc_addr, :bcc_addr, :subject, :htmlbody, :textbody)
    #   attr_accessor :email
    #   def initialize(opts)
    #     @email = Email.new(opts[:encoding], opts[:source], opts[:to_addr], opts[:cc_addr], opts[:bcc_addr], opts[:subject], opts[:htmlbody], opts[:textbody] )
    #   end
    # end

    # def new_email(attributes = {})
    #   email = PlainEmail.new(attributes)
    # end



    def addr_validate(raw_addr)
      unless raw_addr.empty?
        values = raw_addr.split(",")
        addr = []
        values.each do |value|
          addr << value.strip
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

    def send_email(plain_email)
      @success = false
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
      rescue Aws::SES::Errors::ServiceError => error
        puts "Error Occured : #{error}"
        @success = false
      end
      @success = true
      logger.warn "email sent success ? " + @success.to_s
      # redirect_to({ :controller => 'emails', :action=>'index' }, :notice => "Email sent successfully to #{to_addr} ")
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

    def verified_emails
      verified_emails, pending_emails = list_verified_emails
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

    def list_verified_emails
      attrs = Hash.new
      @all_verified_identities = []
      verified_emails = []
      pending_emails = []
      begin
        ses_client = create_ses_client
        # Get up to 1000 identities
        ids = ses_client.list_identities({
          identity_type: "EmailAddress"
        })
        # logger.debug "ID iden size #{ids.identities.size}"
        # logger.debug "ID iden class #{ids.identities.class}" #Array
        id = 0
        ids.identities.each do |email|
          attrs = ses_client.get_identity_verification_attributes({
            identities: [email]
          })
          status = attrs.verification_attributes[email].verification_status
          # Add id to each entry of verified identities 
          id += 1
          identity_hash = {:id => id,:email => email, :status => status}
          @all_verified_identities.push(identity_hash)

          # logger.debug "all_identities_hash#{identity_hash}"
          # logger.debug "all_verified_identities #{all_verified_identities}"

          #keep it on its own function
          if ! email.include?('@activation.email.global.cloud.sap')
            if status == "Success"
              # verified_email_hash = {:email => email, :status => status}
              verified_email_hash = {:id => id,:email => email, :status => status}
              logger.debug "verified_email_hash : #{verified_email_hash}"
              verified_emails.push(verified_email_hash)
            elsif status == "Pending"
              # pending_email_hash = {:email => email, :status => status}
              pending_email_hash = {:id => id,:email => email, :status => status}
              logger.debug "pending_email_hash : #{pending_email_hash}"
              pending_emails.push(pending_email_hash)
            end
          end

        end
      rescue Aws::SES::Errors::ServiceError => error
        logger.debug "error while listing verified emails. Error message: #{error}"
      end
      [verified_emails, pending_emails]
    end

    def remove_verified_identity(identity)
      ses = create_ses_client
      status = ""
        begin
          ses.delete_identity({
            identity: identity
          })
          status = "success"
          # redirect_to({ :controller => 'emails', :action=>'index' }, :notice => "#{identity} is removed from list of verfied identities")
        rescue Aws::SES::Errors::ServiceError => error
          status = "#{error}"
          # redirect_to({ :controller => 'emails', :action=>'index' }, :notice => "Removal of verified email failed. Error message: #{error}")
        end
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


