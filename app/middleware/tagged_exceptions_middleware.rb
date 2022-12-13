class TaggedExceptionsMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  rescue StandardError
    env["exception.token"] ||= env["action_dispatch.request_id"] ||
      SecureRandom.hex(4).upcase
    raise $!, "[#{env["exception.token"]}] #{$!}", $!.backtrace
  end
end
