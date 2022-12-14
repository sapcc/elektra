class DebugHeadersMiddleware
  def initialize(app, _options = {})
    @app = app
  end

  def call(env)
    if env["PATH_INFO"] == "/system/headers"
      _, headers, = @app.call(env)
      body = headers.map { |k, v| "#{k}=#{v}" }.sort.join("\n")
      [
        200,
        { "Content-Type" => "text/plain", "Content-Length" => body.size.to_s },
        [body],
      ]
    else
      @app.call(env)
    end
  end
end
