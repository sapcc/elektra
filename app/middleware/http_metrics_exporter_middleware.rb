# frozen_string_literal: true

require 'prometheus/middleware/exporter'

# This middleware exports metrics under /metrics (default) path
class HttpMetricsExporterMiddleware < Prometheus::Middleware::Exporter
  
  # we unset csp for this endpoint (/metrics)
  def call(env)
    # env["HTTP_HOST"] = env["HTTP_HOST"] || "elektra.cloud.sap" if env['PATH_INFO'] == "/metrics"
    
    return super(env)
    # result = super(env)

    
    # if env['PATH_INFO'] == "/metrics"
    #   request = ActionDispatch::Request.new env
    #   # current path is /metrics
    #   # disable csp from env -> prometheus is able to call this endpoint without host header
    #   request.content_security_policy = false if request.content_security_policy
    #   # env.delete("action_dispatch.content_security_policy")
    # end
    # return result
  end
end