module EmailService
  module AwsSesHelper

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

    def send_email(plain_email)
      success = false
      ses_client = create_ses_client
      begin
        ses_client.send_email(
          destination: {
            to_addresses: plain_email.email.to_addr,
            cc_addresses: plain_email.email.cc_addr,
            bcc_addresses: plain_email.email.bcc_addr
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
        success = true
      rescue Aws::SES::Errors::ServiceError => error
        success = false
        puts "Email not sent. Error message: #{error}"
      end
      # redirect_to({ :controller => 'emails', :action=>'index' }, :notice => "Email sent successfully to #{to_addr} ")
    end


    def get_ec2_creds
      result = services.email_service.get_aws_creds(current_user.id)
      # aws_creds = result[:items]
      # h = aws_creds[0]
      h = result[:items][0]
      access = h.access
      secret = h.secret
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
      # recipient = params[:email][:address].to_s
      if recipient != nil && ! recipient.include?("sap.com")
        begin
          ses_client.verify_email_identity({
          email_address: recipient
          })
          flash.now[:success] = "Verification email sent successfully to #{recipient}"
          redirect_to plugin('email_service').verifications_path

        rescue Aws::SES::Errors::ServiceError => error
          flash.now[:warning] = "Email verification failed. Error message: #{error}"
          redirect_to plugin('email_service').verifications_path  
        end
      end
      if recipient.include?("sap.com")
        flash.now[:warning] = "sap.com domain email addresses are not allowed to verify as a sender(#{recipient})"
        redirect_to plugin('email_service').verifications_path  
      end
    end

    def list_verified_emails
      attrs = Hash.new
      verified_emails = []
      pending_emails = []
      emails_list_hash = []
      begin
        ses_client = create_ses_client
        # Get up to 1000 identities
        ids = ses_client.list_identities({
          identity_type: "EmailAddress"
        })
        ids.identities.each do |email|
          attrs = ses_client.get_identity_verification_attributes({
            identities: [email]
          })
          status = attrs.verification_attributes[email].verification_status
          # email_list = {:email => email, :status => status}
          # emails_list_hash.push(email_list)
          # puts "The verification status of #{email} is #{status}"

          if status == "Success"
            verified_email_hash = {:email => email, :status => status}
            verified_emails.push(verified_email_hash)
          elsif status == "Pending"
            pending_email_hash = {:email => email, :status => status}
            pending_emails.push(pending_email_hash)
          end
          [verified_emails, pending_emails]
          # return emails_list_hash
        end
      rescue Aws::SES::Errors::ServiceError => error
        puts "error while listing verified emails. Error message: #{error}"
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


