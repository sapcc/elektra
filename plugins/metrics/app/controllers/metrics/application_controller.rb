# frozen_string_literal: true
module Metrics
  class ApplicationController < DashboardController
    helper_method :grafana_available
    authorization_context "metrics"
    authorization_required

    def index
      enforce_permissions("metrics:application_list")
    end

    def maia
      redirect_to "https://maia.#{current_region}.cloud.sap/#{@scoped_domain_name}?x-auth-token=#{current_user.token}"
    end

    def grafana_available
      require "resolv"
      dns_resolver = Resolv::DNS.new()
      begin
        dns_resolver.getaddress("api.grafana-svc.#{current_region}.cloud.sap")
        return true
      rescue Resolv::ResolvError => e
        return false
      end
    end

    def gaas
      uri_grafana =
        URI.parse(
          "https://api.grafana-svc.#{current_region}.cloud.sap/api/v1/grafana",
        )
      uri_proxy =
        URI.parse(
          "https://api.grafana-svc.#{current_region}.cloud.sap/api/v1/grafanaproxy",
        )
      retries = 0
      options = {
        title:
          "grafana as a service has not responded or is not available in this region",
        warning: false,
        sentry: false,
      }
      grafana = {
        config: {
          ingressHost: "%s.grafana-svc.#{current_region}.cloud.sap",
          authProxy: {
            enabled: true,
          },
        },
      }
      grafana_proxy = {
        config: {
          ingressHost: "%s.grafana-svc.#{current_region}.cloud.sap",
          connectors: ["keystone"],
        },
      }

      begin
        Resolv::DNS.new.getresources(
          uri_grafana.to_s,
          Resolv::DNS::Resource::IN::A,
        )
      rescue => e
        print e
      end
      begin
        resp = _request(uri_proxy, grafana_proxy)
      rescue Timeout::Error,
             Errno::EINVAL,
             Errno::ECONNRESET,
             EOFError,
             Errno::ETIMEDOUT,
             Net::HTTPBadResponse,
             Net::HTTPHeaderSyntaxError,
             Net::ProtocolError,
             OpenSSL::SSL::SSLError => e
        render_exception_page(e, options)
        return
      end

      begin
        resp = _request(uri_grafana, grafana)
      rescue Timeout::Error,
             Errno::EINVAL,
             Errno::ECONNRESET,
             EOFError,
             Errno::ETIMEDOUT,
             Net::HTTPBadResponse,
             Net::HTTPHeaderSyntaxError,
             Net::ProtocolError,
             OpenSSL::SSL::SSLError => e
        render_exception_page(e, options)
        return
      end

      if resp.code == "200" or resp.code == "201"
        grafanaHost = JSON[resp.body]["hostname"]
        grafanaHost = URI.parse("https://" + grafanaHost)
        begin
          resp = _request(grafanaHost)
          if resp.code == "302"
            redirect_to grafanaHost.to_s
          else
            raise "grafana is not responding"
          end
        rescue StandardError => e
          if (retries += 1) <= 5
            puts "Timeout (#{e}), retrying in #{retries} second(s)..."
            sleep(retries)
            retry
          else
            render_exception_page(e, options)
          end
        end
      else
        render_exception_page(e, options)
      end
    end

    def _request(uri, body = nil)
      header = {
        "Content-Type": "application/json",
        "x-auth-token": "#{current_user.token}",
      }
      if body
        request = Net::HTTP::Post.new(uri.request_uri, header)
        request.body = body.to_json
      else
        request = Net::HTTP::Get.new(uri.request_uri)
      end
      https = Net::HTTP.new(uri.host, uri.port)
      if ENV.key?("ELEKTRA_SSL_VERIFY_PEER") &&
           (ENV["ELEKTRA_SSL_VERIFY_PEER"] == "false")
        https.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      https.read_timeout = 120
      https.use_ssl = true
      response = https.request(request)
    end
  end
end
