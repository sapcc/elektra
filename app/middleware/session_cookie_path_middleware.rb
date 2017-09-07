# frozen_string_literal: true

# This middleware overwrites the path of session cookie to make it possible
# to handle user sessions based on the current openstack domain.
class SessionCookiePathMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    # call next middleware (the whole stack under this middleware).
    # It also calls rails app and sets the path params which we need here.
    status, headers, response = @app.call(env)
    params = env['action_dispatch.request.path_parameters']
    # get current domain from params or use the default domain
    domain = params[:auth_domain] ||
             params[:domain_name] ||
             params[:domain_id] ||
             Rails.configuration.default_domain

    # change the path of session cookie to current domain
    env['rack.session.options'][:path] = "/#{domain}" if domain

    # and return the status, headers and response
    [status, headers, response]
  end
end
