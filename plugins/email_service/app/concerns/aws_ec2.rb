module AwsEc2
  def ec2_creds
    resp = services.identity.aws_credentials(current_user.id, current_user.project_id)
    if resp.class == Array
      return resp.first
    elsif resp.class == ServiceLayer::IdentityServices::Credential::AWSCreds
      return resp
    end
  end

  def ses_client
    region = map_region(current_user.default_services_region)
    endpoint = current_user.service_url('email-aws')
    if ec2_creds.error.empty?
      begin
        credentials = Aws::Credentials.new(ec2_creds.access, ec2_creds.secret)
        ses_client = Aws::SES::Client.new(region: region, endpoint: endpoint, credentials: credentials)
      rescue Aws::SES::Errors::ServiceError => error
        return error
      end  
    end
    ses_client ? ses_client : ec2_creds.error
  end

  def map_region(region)
    aws_region = ""
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
