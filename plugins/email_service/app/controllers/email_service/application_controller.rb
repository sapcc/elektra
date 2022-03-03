# frozen_string_literal: true

module EmailService
  class ApplicationController < ::DashboardController
    
    include ::EmailService::ApplicationHelper

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

    def check_ec2_creds_cronus_status
      if ( !ec2_creds && ec2_creds.nil? ) || !nebula_active?
        render '/email_service/shared/setup.html'
      end
    end

    protected
    
    helper_method :release_state

    # Overwrite this method in your controller if you want to set the release
    # state of your plugin to a different value. A tag will be displayed in
    # the main toolbar next to the page header
    # DON'T OVERWRITE THE VALUE HERE IN THE DASHBOARD CONTROLLER
    # Possible values:
    # ----------------
    # "public_release"  (plugin is properly live and works, default)
    # "experimental"    (for plugins that barely work or don't work at all)
    # "tech_preview"    (early preview for a new feature that probably still
    #                    has several bugs)
    # "beta"            (if it's almost ready for public release)
    def release_state
      'tech_preview'
    end

  end
end
