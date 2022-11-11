module EmailService
  class EmailsController < ::EmailService::ApplicationController

    before_action :check_ec2_creds_cronus_status
    before_action :check_verified_identity

    authorization_context 'email_service'
    authorization_required

    def index
    end

  end
end
