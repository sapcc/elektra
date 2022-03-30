module EmailService
  class StatsController < ::EmailService::ApplicationController
    # before_action :restrict_access
    before_action :check_ec2_creds_cronus_status
    
    authorization_context 'email_service'
    authorization_required
    
    def index
    end

  end
end
