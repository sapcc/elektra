module EmailService
  class StatsController < ::EmailService::ApplicationController
    before_action :restrict_access

    authorization_context 'email_service'
    authorization_required
    
    def index
      creds = get_ec2_creds
      if creds.error.empty?
        @send_stats = get_send_stats
      else
        flash[:error] = creds.error
      end
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
      rescue Exception => e
        flash[:error] = "Status Code: 500 : Error: #{e.message}"
    end

  end
end
