# frozen_string_literal: true

module Metrics
  class ApplicationController < DashboardController
    authorization_context 'metrics'
    authorization_required

    def index
      enforce_permissions('metrics:application_list')
    end

    def maia
      redirect_to "https://maia.#{current_region}.cloud.sap/#{@scoped_domain_name}?x-auth-token=#{current_user.token}"
    end

    def gaas
      grafana = {
        "config": {
          "ingressHost": "%s.grafana-svc.qa-de-1.cloud.sap",
          "logLevel": "info",
          "basicAuth": false,
          "disableLoginForm": true,
          "orgName": "sapcc",
          "includeRolesInGroups": true,
          "grafanaGroupRoleMap": "admin:Admin network_admin:Editor",
          "authProxy": {
            "enabled": true
          }
        }
      }
      uri = URI.parse("https://api.grafana-svc.#{current_region}.cloud.sap/api/v1/grafana")

      header = {
        "Content-Type": "application/json",
        "x-auth-token": "#{current_user.token}"
      }
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri, header)
      request.body = grafana.to_json
    
      # Send the request
      response = https.request(request)
      if response.code == '200' or response.code == '201'
        body = JSON[response.body]
        redirect_to "https://"+ body['hostname']
      end
    end

  end
end
