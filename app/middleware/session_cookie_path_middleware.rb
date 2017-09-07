class SessionCookiePathMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    # call next middleware (the whole stack under this middleware).
    # It also calls rails app and sets the path params which we need here.
    status, headers, response = @app.call(env)
    params = env['action_dispatch.request.path_parameters']
    domain = params[:auth_domain] || params[:domain_name] || params[:domain_id]
    p ">>>>>>>>>>>>>>>>domain: #{domain}"
    p ">>>>>>>>>>>>>>>>params: #{params}"
    if domain
      env['rack.session.options'][:path] = "/#{domain}"
    else
      #env["rack.session"].clear
    end
    p ">>>>>>>>>>>>>>>>new path: #{env['rack.session.options'][:path]}"
    byebug
    # byebug

    [status, headers, response]
  end

  # For this version you should order this middleware before ActionDispatch::Cookies
  # in application.rb: config.middleware.insert_before ActionDispatch::Cookies, SessionCookiePathMiddleware
  # def call(env)
  #   status, headers, response = @app.call(env)
  #   session_cookie = headers['Set-Cookie']
  #   if session_cookie
  #     session_key = Rails.configuration.session_options
  #                        .with_indifferent_access[:key]
  #     if session_cookie.include?(session_key)
  #       params = env['action_dispatch.request.path_parameters']
  #       domain = params[:auth_domain] || params[:domain_name] || params[:domain_id]
  #       if domain
  #         new_session_cookie = session_cookie.gsub(/(?<name>#{session_key}.*)path=[^\;]*/,'\k<name>path=/'+domain.to_s)
  #         headers['Set-Cookie'].gsub!(session_cookie, new_session_cookie)
  #       else
  #         headers.delete('Set-Cookie')
  #       end
  #     end
  #     byebug
  #   end
  #   [status, headers, response]
  # end
end
