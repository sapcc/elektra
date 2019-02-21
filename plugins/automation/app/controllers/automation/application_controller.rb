module Automation
  class ApplicationController < DashboardController
    rescue_from 'ArcClient::ApiError' do |exception|
      if exception.respond_to?(:code) && (exception.code == 401 || exception.code == 403)
        options = {
          title: 'Unauthorized',
          sentry: false,
          warning: true,
          status: exception.code,
          description: "You are not authorized to view this page. #{exception.detail}"
        }
      else
        options = {
          title: :title,
          description: :detail,
          warning: true,
          sentry: true,
          status: exception.code
        }
      end

      if params[:polling_service]
        head options[:status]
      else
        render_exception_page(exception, options)
      end
    end

    rescue_from 'MonsoonOpenstackAuth::Authorization::SecurityViolation' do |exception|
      if exception.resource[:action] == 'index' && exception.resource[:controller] == 'automation/nodes'
        @title = 'Unauthorized'
        @status = 401
        @description = 'You are not authorized to view this page.'
        if exception.respond_to?(:involved_roles) && exception.involved_roles && exception.involved_roles.length.positive?
          @description += " Please check (role assignments) if you have one of the following roles: #{exception.involved_roles.flatten.join(', ')}."
        end
        render '/automation/shared/warning.html', status: @status
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
  end
end
