module EmailService
  class WebController < ::EmailService::ApplicationController
    before_action :ui_switcher

    def index
      # enforce_permissions('email_service:application_list')
      # enforce_permissions('email_service:configset_list')
    end

    
  end
end
