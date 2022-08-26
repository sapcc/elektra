# frozen_string_literal: true

require 'prometheus/middleware/collector'

# HttpMetricsMiddleware is a Rack middleware that provides an implementation of a
# elektra HTTP tracer.
class HttpMetricsCollectorMiddleware < Prometheus::Middleware::Collector
  def initialize(app, options = {}) 
    options[:counter_label_builder] ||= proc do |env, code|
      path_params = env['action_dispatch.request.path_parameters'] || {}
      controller_name = path_params[:controller] || ''
      is_health_controller = ['health'].include?(controller_name)

      {
        code: code,
        method: env['REQUEST_METHOD'].downcase,
        host: env['HTTP_HOST'].to_s,
        # just take the first component of the path as a label
        path: is_health_controller ? env['REQUEST_PATH'] : env['REQUEST_PATH'][0, env['REQUEST_PATH'].index('/', 1) || 20],
        controller: controller_name,
        action: path_params[:action] || '',
        plugin: is_health_controller ? controller_name : controller_name[%r{^([^/]+)/}, 1]
      }
    end
    options[:duration_label_builder] ||= proc do |env, _code|
      controller_name = (env['action_dispatch.request.path_parameters'] || {})[:controller] || ''
      {
        method: env['REQUEST_METHOD'].downcase,
        plugin: ['health'].include?(controller_name) ? controller_name : controller_name[%r{^([^/]+)/}, 1]
      }
    end

    super(app, options)
  end

end

