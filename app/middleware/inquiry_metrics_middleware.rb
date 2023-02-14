# frozen_string_literal: true

# This middleware collects the inquiry (elektra request) metrics
class InquiryMetricsMiddleware
  def initialize(app, options = {})
    @app = app
    @registry = options[:registry] || Prometheus::Client.registry
    @path = options[:path] || "/metrics"

    @open_inquiry_metrics =
      @registry.get(:elektra_open_inquiry_metrics) ||
        @registry.gauge(
          :elektra_open_inquiry_metrics,
          docstring: "A gauge of open elektra requests",
          labels: %i[region domain kind],
        )
  end

  def call(env)
    # if current path is /metrics
    if env["PATH_INFO"] == @path
      # reset all values to zero
      @open_inquiry_metrics.values.each do |labels, _value|
        @open_inquiry_metrics.set(0, { labels: labels })
      end

      # collect all metrics
      metrics.each do |data|
        count = data.delete(:count)
        @open_inquiry_metrics.set(
          count,
          labels: { region: Rails.configuration.default_region }.merge(data),
        )
      end
    end

    # and call rest of middleware stack
    @app.call(env)
  end

  # calculate request metrics
  def metrics
    inquiry_data =
      ::Inquiry::Inquiry.where(aasm_state: "open").pluck(:domain_id, :kind)

    # collect domain ids
    domain_ids = inquiry_data.collect { |i| i[0] }

    # domain id => domain name
    domain_id_names =
      FriendlyIdEntry
        .where(key: domain_ids.uniq)
        .pluck(:key, :name)
        .each_with_object({}) { |d, memo| memo[d[0]] = d[1] }

    inquiry_data
      .each_with_object({}) do |i, hash|
        key = "#{i[0]}-#{i[1]}"
        hash[key] ||= {
          domain: domain_id_names[i[0]] || i[0],
          kind: i[1],
          count: 0,
        }
        hash[key][:count] += 1
      end
      .values
  end
end
