module EmailService
  class EmailsController < ::EmailService::ApplicationController
    before_action :restrict_access
    before_action :check_user_creds_roles

    authorization_context 'email_service'
    authorization_required

    def index
    end

  end
end

