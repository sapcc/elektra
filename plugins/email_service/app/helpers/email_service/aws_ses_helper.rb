# require 'logger'
module EmailService
  module AwsSesHelper
    include TemplateHelper
    @encoding = "utf-8"

    ### EC2 CREDS ### 
    def get_ec2_creds
      resp = services.identity.aws_credentials(current_user.id, current_user.project_id)
      if resp.class == ServiceLayer::IdentityServices::Credential::AWSCreds
        if resp["error"]
          puts resp["error"]
        end
      elsif resp.class == Array
        credentials = resp.first
      end
      credentials.nil? ? resp : credentials
    end

    ### CREATE SES CLIENT ###
    def create_ses_client
      region = map_region(current_user.default_services_region)
      endpoint = current_user.service_url('email-aws')
      begin
        creds =  get_ec2_creds
        credentials = Aws::Credentials.new(creds.access, creds.secret)
        ses_client = Aws::SES::Client.new(region: region, endpoint: endpoint, credentials: credentials)
      rescue Aws::SES::Errors::ServiceError => error
        puts "Error is : #{error}"
      end
    end

    # Get send data
    def get_send_data
      resp_hash = {}
      ses_client = create_ses_client
      resp = ses_client.get_send_quota({})
      resp_hash = resp.to_h
    end

    def get_send_stats
      stats_arr  = []
      begin
        ses_client = create_ses_client
        resp = ses_client.get_send_statistics({})
        datapoints = resp.send_data_points

        index = 0
        while datapoints.size > 0 && index < datapoints.count
          stats_hash = { timestamp: datapoints[index].timestamp, delivery_attempts: datapoints[index].delivery_attempts, bounces: datapoints[index].bounces, rejects: datapoints[index].rejects, complaints: datapoints[index].complaints }
          stats_arr.push(stats_hash)
          index += 1
        end
      rescue Aws::SES::Errors::ServiceError => error
        logger.debug "CRONUS SEND : #{error}" 
      end
      stats_arr.sort_by! { |hsh| hsh[:timestamp] } 
      stats_arr.reverse!
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
end