module EmailService
  class EmailsController < ::EmailService::ApplicationController

    before_action :restrict_access

    authorization_context 'email_service'
    authorization_required

    def index

    end

  end
end

