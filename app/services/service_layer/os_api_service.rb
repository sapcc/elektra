# This service only exists to provide the API client elektron
# Use case rever_proxy (see os_api_controller.rb)
module ServiceLayer
  class OsApiService < Core::ServiceLayer::Service
    def service(name)
      if  Rails.env.development?
        service = elektron.service(name,interface: "public")
      else
        begin 
          service = elektron.service(name,interface: "internal")
          # check if internal interface is available
          service.endpoint_url(interface: "internal")
        rescue Elektron::Errors::ServiceEndpointUnavailable
          service = elektron.service(name,interface: "public")
        end
      end
      service
    end
  end
end
