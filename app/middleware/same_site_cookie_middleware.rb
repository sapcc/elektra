class SameSiteCookieMiddleware
  COOKIE_SEPARATOR = "\n".freeze
  def initialize(app)
    @app = app
  end
  def call(env)

    status, headers, body = @app.call(env)
    if headers['Set-Cookie'].present?
      cookies = headers['Set-Cookie'].split(COOKIE_SEPARATOR)
      cookies.each do |cookie|
        next if cookie.blank?
        unless cookie =~ /;\s*samesite=/i
          cookie << '; SameSite=Lax'
        end
      end

      headers['Set-Cookie'] = cookies.join(COOKIE_SEPARATOR)
    end
    [status, headers, body]
  end
  
end
