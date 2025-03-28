# frozen_string_literal: true

module Resources
  class ApplicationController < DashboardController
    def bigvm_resources

      if @scoped_project_id.nil?
        # domain level
        openstack_level = "domain/#{@scoped_domain_id}"
      else
        # project level
        openstack_level = "project/#{@scoped_project_id}"
      end
      
      # API Docu
      # https://migration-recommender-service.cca-pro.cerebro.c.eu-de-1.cloud.sap/public/docs#/default/get_placeable_vm_for_project_api_v1_placeable_vm_project__openstack_project_id__get
      require "net/http"
      begin
        cerebro_endpoint = "https://migration-recommender-service.#{current_region}.cloud.sap/public/api/v1/placeable-vm/#{openstack_level}"
        if ENV.key?("CEREBRO_CUSTOM_ENDPOINT") && ENV["CEREBRO_CUSTOM_ENDPOINT"].present? 
          cerebro_endpoint = "#{ENV['CEREBRO_CUSTOM_ENDPOINT']}/public/api/v1/placeable-vm/#{openstack_level}"
        end

        # for debug and development use a region and project or domain
        # https://migration-recommender-service.eu-de-1.cloud.sap/public/docs
        # check eu-de-1 and get the project or domain id
        # cerebro_endpoint = "https://migration-recommender-service.eu-de-1.cloud.sap/public/api/v1/placeable-vm/domain/XXX"
        # cerebro_endpoint = "https://migration-recommender-service.eu-de-1.cloud.sap/public/api/v1/placeable-vm/project/XXX

        uri = URI(cerebro_endpoint)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        if ENV.key?("ELEKTRA_SSL_VERIFY_PEER") &&
          (ENV["ELEKTRA_SSL_VERIFY_PEER"] == "false")
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        
        response = http.get(uri)
        if response.code == "200"
          big_vm_data = response.body
        else
          render json: { error: "Couldn't retrieve bigVM resources. No Data available. API response: #{response.message}" }, status: 422
          return
        end
      rescue StandardError => e
        render json: { error: "Couldn't load bigVMData, ist the API available in this region?" }, status: 422
        return
      end
      render json: big_vm_data
    end
  end
end
