# This service only exists to provide the API client elektron
# Use case rever_proxy (see os_api_controller.rb)
module ServiceLayer
  class OsApiService < Core::ServiceLayer::Service
    def service(name,options={})
      elektron.service(name,options)
    end
  end
end
