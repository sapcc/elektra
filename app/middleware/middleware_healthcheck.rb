class MiddlewareHealthcheck
  OK_RESPONSE = [ 200, { 'Content-Type' => 'text/plain' }, ["It's alive! It only checks that a request reaches the Middleware layer, no db connection needed.".freeze] ]

  def initialize(app)
    @app = app
  end

  def call(env)
    if env['PATH_INFO'.freeze] == '/system/lifeliness'.freeze
      return OK_RESPONSE
    else
      @app.call(env)
    end
  end
end
