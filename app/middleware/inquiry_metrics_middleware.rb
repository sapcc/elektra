# frozen_string_literal: true

# This middleware collects the inquiry (elektra request) metrics
class InquiryMetricsMiddleware
  def initialize(app, options = {})
    @app = app
    @registry = options[:registry] || Prometheus::Client.registry
    @path = options[:path] || '/metrics'
    @inquiry_metrics = @registry.gauge(:inquiry_metrics, 'A gauge of elektra requests')
  end

  def call(env)
    if env['PATH_INFO'] == @path
      
      @inquiry_metrics.set({ region: 'staging', domain: 'monsoon3', type: 'project', status: 'open', url: 'https://dashboard.staging.cloud.sap'}, 3)
    end

    # and return the status, headers and response
    @app.call(env)
  end
end
