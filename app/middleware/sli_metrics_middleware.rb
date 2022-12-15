# frozen_string_literal: true

require "benchmark"

# This middleware collects the Service Level Indicator metrics
class SLIMetricsMiddleware
  def initialize(app, options = {})
    @app = app
    @registry = options[:registry] || Prometheus::Client.registry
    @path = options[:path] || "/metrics"

    @histogram =
      @registry.get(:elektra_sli) ||
        @registry.histogram(
          :elektra_sli,
          docstring: "A histogram if sli",
          labels: %i[path method],
        )
  end

  def call(env)
    # trace latency metrics if landing page
    if ![@path, "/assets"].include?(env["PATH_INFO"]) &&
         %r{^/[^/]+/?$}.match?(env["PATH_INFO"])
      response = nil
      duration = Benchmark.realtime { response = @app.call(env) }
      @histogram.observe(
        duration,
        labels: {
          path: env["PATH_INFO"],
          method: env["REQUEST_METHOD"].downcase,
        },
      )
      return response
    end

    @app.call(env)
  end
end
