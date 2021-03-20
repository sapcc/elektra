module EmailService
  module AwsSesHelper

    def get_ec2_creds
      result = services.email_service.get_aws_creds(current_user.id)
      aws_creds = result[:items]
      # h = Hash.new
      h = aws_creds[0]
      access = h.access
      secret= h.secret
      [access, secret]
    end

    def create_ses_client
      region = map_region(current_user.default_services_region) #|| 'eu-central-1'
      endpoint = current_user.service_url('email-aws')# || 'https://cronus.qa-de-1.cloud.sap'
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
          redirect_to({ :controller => 'emails', :action=>'index' }, :notice => "Verification email sent successfully to #{recipient}")
  
        rescue Aws::SES::Errors::ServiceError => error
          redirect_to({ :controller => 'emails', :action=>'index' }, :notice => "Email verification failed. Error message: #{error}")
        end
      end
      if recipient.include?("sap.com")
        puts "You can't verify an SAP domain email address "
        redirect_to({ :controller => 'emails', :action=>'index' }, :notice => "sap.com domain email is not allowed to verify as a sender(#{recipient})")
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


