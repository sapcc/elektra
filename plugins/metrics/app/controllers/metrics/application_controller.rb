# frozen_string_literal: true

module Metrics
  class ApplicationController < DashboardController
    authorization_context 'metrics'
    authorization_required
    extend ErrorRenderer

    def index
      enforce_permissions('metrics:application_list')
    end

    def maia
      redirect_to "https://maia.#{current_region}.cloud.sap/#{@scoped_domain_name}?x-auth-token=#{current_user.token}"
    end

    def gaas
      options = {
        title: "cannot open maia grafana",
        warning: true, sentry: false
      }
      grafana = {
        "config": {
          "ingressHost": "%s.grafana-svc.#{current_region}.cloud.sap",
          "authProxy": {
            "enabled": true
          }
        }
      }
      grafana_proxy = {
        "config": {
          "ingressHost": "%s.grafana-svc.#{current_region}.cloud.sap",
          "connectors": ["keystone"]
        }
      }
      uri_grafana = URI.parse("https://api.grafana-svc.#{current_region}.cloud.sap/api/v1/grafana")
      uri_proxy = URI.parse("https://api.grafana-svc.#{current_region}.cloud.sap/api/v1/grafanaproxy")

      begin
        resp = _request(uri_proxy, grafana_proxy)
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
        Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError, OpenSSL::SSL::SSLError => e
        render_exception_page(e, options)
        return
      end

      begin
        resp = _request(uri_grafana, grafana)
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
        Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError, OpenSSL::SSL::SSLError => e
        render_exception_page(e, options)
        return
      end

      if resp.code == '200' or resp.code == '201'
        body = JSON[resp.body]
        redirect_to "https://"+ body['hostname']
      else
        render_exception_page(e, options)
      end
    end

    def _request(uri, body)
      header = {
        "Content-Type": "application/json",
        "x-auth-token": "#{current_user.token}"
      }
      https = Net::HTTP.new(uri.host, uri.port)
      https.read_timeout = 60
      https.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri, header)
      request.body = body.to_json
      response = https.request(request)
    end

  end
end
