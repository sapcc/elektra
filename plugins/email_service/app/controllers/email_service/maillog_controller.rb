module EmailService
  class MaillogController < ::EmailService::ApplicationController
    authorization_context 'email_service'
    authorization_required

    def index

    end
  end
end
