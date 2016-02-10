class TaggedExceptionsMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  rescue 
    env['exception.token'] ||= SecureRandom.hex(4).upcase
    raise $!, "[#{env['exception.token']}] #{$!}", $!.backtrace
  end
end
