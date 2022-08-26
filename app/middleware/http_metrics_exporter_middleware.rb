# frozen_string_literal: true

require 'prometheus/middleware/exporter'

# This middleware exports metrics under /metrics (default) path
class HttpMetricsExporterMiddleware < Prometheus::Middleware::Exporter
  
  # we unset csp for this endpoint (/metrics)
  def call(env)
    result = super(env)

    if env['PATH_INFO'] == "/metrics"
      # current path is /metrics
      # delete csp from env -> prometheus is able to call this endpoint without host header
      env.delete("action_dispatch.content_security_policy")
    end
    return result
  end
end