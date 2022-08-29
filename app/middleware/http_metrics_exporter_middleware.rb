# frozen_string_literal: true

require 'prometheus/middleware/exporter'

# This middleware exports metrics under /metrics (default) path
# If you want to expand the exporter, this would be the right place for it 
class HttpMetricsExporterMiddleware < Prometheus::Middleware::Exporter
  # def initialize(app, options = {})
  #   super(app, options = {})
  # end

  # def call(env)
  #   super(env)
  # end
end