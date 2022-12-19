class DebugEnvMiddleware
  def initialize(app, options = {})
    @app = app
  end

  def call(env)
    if env["PATH_INFO"] == "/system/env"
      body = env.map { |k, v| "#{k}=#{v}" }.sort.join("\n")
      body += "\n\n #{}"
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
