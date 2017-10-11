# frozen_string_literal: true

# This middleware collects the inquiry (elektra request) metrics
class InquiryMetricsMiddleware
  def initialize(app, options = {})
    @app = app
    @registry = options[:registry] || Prometheus::Client.registry
    @path = options[:path] || '/metrics'
    @open_inquiry_metrics = @registry.gauge(
      :open_inquiry_metrics, 'A gauge of elektra requests'
    )
  end

  def call(env)
    if env['PATH_INFO'] == @path

      metrics.each do |data|
        @open_inquiry_metrics.set(
          { region: Rails.configuration.default_region }.merge(data[:values]),
          data[:count]
        )
      end
    end

    # and return the status, headers and response
    @app.call(env)
  end

  def metrics
    inquiry_data = ::Inquiry::Inquiry.where(aasm_state: 'open').pluck(
      :domain_id, :approver_domain_id, :project_id, :kind, :callbacks
    )

    # collect ids
    ids = inquiry_data.each_with_object(
      { domain_ids: [], approver_domain_ids: [], project_ids: [] }
    ) do |i,memo|
      memo[:domain_ids] << i[0]
      memo[:approver_domain_ids] << i[1]
      memo[:project_ids] << i[2]
    end

    # closure
    id_names = lambda { |kind_ids|
      FriendlyIdEntry.where(key: kind_ids.uniq)
                     .pluck(:key, :name)
                     .each_with_object({}) { |d, memo| memo[d[0]] = d[1] }
    }
    # id => name
    domain_names = id_names.call(ids[:domain_ids])
    project_names = id_names.call(ids[:project_ids])
    approver_domain_names = id_names.call(ids[:approver_domain_ids])

    inquiry_data.each_with_object({}) do |i, hash|
      key = "#{i[0]}-#{i[1]}-#{i[2]}-#{i[3]}"
      hash[key] ||= {
        values: {
          domain: domain_names[i[0]] || i[0],
          approver_domain: approver_domain_names[i[1]] || i[1],
          project: project_names[i[2]] || i[2],
          kind: i[3],
          url: (i[4] || {}).fetch('approved',{}).fetch('action')
        },
        count: 0
      }
      hash[key][:count] += 1
    end.values
  end
end
