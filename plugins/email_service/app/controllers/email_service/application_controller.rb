# frozen_string_literal: true

module EmailService
  class ApplicationController < DashboardController
    include AwsSesHelper
    include EmailHelper
    include TemplateHelper
    include VerificationsHelper
    include ConfigsetHelper

    authorization_context 'email_service'
    authorization_required

    def ui_switcher
      if current_user.has_role?('cloud_support_tools_viewer')
        redirect_to emails_path
      end
    end
 
    def restrict_access
      unless current_user.has_role?('cloud_support_tools_viewer')
        redirect_to index_path
      end
    end 
    
  end
end
