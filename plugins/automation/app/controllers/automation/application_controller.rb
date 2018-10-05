module Automation
  class ApplicationController < DashboardController
    rescue_from 'ArcClient::ApiError' do |exception|
      options = {
        title: :title,
        description: :detail,
        warning: true, sentry: true
      }

      if params[:polling_service]
        head status: 500
      else
        render_exception_page(exception, options)
      end
    end

    # rescue_and_render_exception_page [
    #   {
    #     "ArcClient::ApiError" => {
    #       header_title: "Monsoon Automation",
    #       details: -> e, c { e.json_hash.empty? ? e.inspect : e.json_hash},
    #       description: :title,
    #       title: :status
    #     }
    #   }
    # ]

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
