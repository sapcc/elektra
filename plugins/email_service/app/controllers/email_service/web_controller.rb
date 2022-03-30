module EmailService
  class WebController < ::EmailService::ApplicationController
    # before_action :ui_switcher

    authorization_context 'email_service'
    authorization_required

    def index
    end

    
  end
end