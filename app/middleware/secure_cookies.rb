# In production, we flag all cookies sent by the application to be "Secure".

class SecureCookies
  COOKIE_SEPARATOR = "\n".freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)

    if headers["Set-Cookie"].present? && Rails.env == "production"
      cookies = headers["Set-Cookie"].split(COOKIE_SEPARATOR)

      cookies.each do |cookie|
        next if cookie.blank?
        next if cookie =~ /;\s*secure/i

        cookie << "; Secure"
      end

      headers["Set-Cookie"] = cookies.join(COOKIE_SEPARATOR)
    end

    [status, headers, body]
  end
end
