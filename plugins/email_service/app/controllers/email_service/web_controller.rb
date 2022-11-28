module EmailService
  class WebController < ::EmailService::ApplicationController
    # before_action :ui_switcher

    before_action :check_ec2_creds_cronus_status

    authorization_context 'email_service'
    authorization_required

    def index
    end

  end
end
