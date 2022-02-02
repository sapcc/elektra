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
    
    # Handle exception related to roles
    rescue_from 'MonsoonOpenstackAuth::Authorization::SecurityViolation' do |exception|
      if exception.resource[:action] == 'index' && exception.resource[:controller] == 'email_service/emails'
        @title = 'Unauthorized'
        @status = 401
        @description = 'You are not authorized to view this page.'
        if exception.respond_to?(:involved_roles) && exception.involved_roles && exception.involved_roles.length.positive?
          @description += " Please check (role assignments) if you have one of the following roles: #{exception.involved_roles.flatten.join(', ')}."
        end
        render '/email_service/shared/warning.html', status: @status
      end

      options = {
        title: 'Unauthorized',
        sentry: false,
        warning: true,
        status: 401,
        description: lambda do |e, _c|
          m = 'You are not authorized to view this page.'
          if e.involved_roles && e.involved_roles.length.positive?
            m += " Please check (role assignments) if you have one of the \
          following roles: #{e.involved_roles.flatten.join(', ')}."
          end
          m
        end
      }

      render_exception_page(exception, options)
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
