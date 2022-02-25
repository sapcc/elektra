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
      unless ec2_creds && !ec2_creds.nil? || nebula_active?
        render '/email_service/shared/setup.html'
      end
    end 
    
    # Handle exception related to roles
    rescue_from 'MonsoonOpenstackAuth::Authorization::SecurityViolation' do |exception|

      actions = [ 'index', 
                  'new', 
                  'create', 
                  'update', 
                  'destroy', 
                  'show', 
                  'verify_dkim', 
                  'activate_dkim', 
                  'deactivate_dkim'  
                ]

      controllers = [ 'email_service/emails', 
                      'email_service/configsets', 
                      'email_service/emails',
                      'email_service/configsets',
                      'email_service/plain_emails',
                      'email_service/templated_emails',
                      'email_service/emails',
                      'email_service/templates',
                      'email_service/configsets',
                      'email_service/email_verifications',
                      'email_service/stats',
                      'email_service/domain_verifications',
                      'email_service/settings',
                      'email_service/custom_verification_email_templates',
                      'email_service/multicloud_accounts',
                      'email_service/ec2_credentials',
                      'email_service/web'
                    ]

      if actions.include?(exception.resource[:action]) && controllers.include?(exception.resource[:controller])
        @title = 'Unauthorized'
        @status = 401
        @description = 'You are not authorized to view this page.'
        if exception.respond_to?(:involved_roles) && exception.involved_roles && exception.involved_roles.length.positive?
          @description += " Please check (role assignments) if you have one of the following roles: #{exception.involved_roles.flatten.join(', ')}."
        end
        render '/email_service/shared/role_warning.html'
      end

      # render '/email_service/shared/role_warning.html'

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
