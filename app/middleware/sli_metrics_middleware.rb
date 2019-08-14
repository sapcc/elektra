# frozen_string_literal: true

require 'benchmark'

# This middleware collects the Service Level Indicator metrics
class SLIMetricsMiddleware
  def initialize(app, options = {})
    @app = app
    @registry = options[:registry] || Prometheus::Client.registry
    @path = options[:path] || '/metrics'

    @histogram = @registry.get(:elektra_sli) || @registry.histogram(
                              :elektra_sli,
                              'A histogram if sli'
                            )
  end

  def call(env)
    # trace latency metrics if landing page
    if ![@path, '/assets'].include?(env['PATH_INFO']) && /^\/[^\/]+\/?$/.match?(env['PATH_INFO'])
      response = nil
      duration = Benchmark.realtime { response = @app.call(env) }
      @histogram.observe({path: env['PATH_INFO'], method: env['REQUEST_METHOD'].downcase}, duration)
      return response
    end
    
    @app.call(env)
  end
end
