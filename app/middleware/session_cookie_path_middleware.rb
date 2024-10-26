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

    # get current domain from params or use the default domain.
    # We use friendly id helper to make domain and project names url safe.
    # That can lead to differences between domain name and its friendly id. So
    # the order we check the current domain is friendly id,
    # domain name or domain id.
    domain =
      params[:domain_fid] || params[:domain_name] || params[:domain_id] ||
      Rails.configuration.default_domain

    # change the path of session cookie to current domain
    env['rack.session.options'][:path] = "/#{domain}" if domain

    # and return the status, headers and response
    [status, headers, response]
  end
end
