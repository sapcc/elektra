require_relative 'domain_model_service_layer/driver/base'
require_relative 'domain_model_service_layer/fog_driver/client_helper'
require_relative 'domain_model_service_layer/errors'
require_relative 'domain_model_service_layer/api_error_handler'
require_relative 'domain_model_service_layer/model'

# implements service layer and domain model
module DomainModelServiceLayer
  # this module is included in controllers
  module Services
    def self.included(base)
      base.send :include, InstanceMethods
      base.send :helper_method, :services
    end

    module InstanceMethods
      # load services provider
      def services(region=nil)
        # initialize services unless already initialized
        unless @services
          region ||= auth_session.region if auth_session
          region ||= MonsoonOpenstackAuth.configuration.default_region
          
          if MonsoonOpenstackAuth.configuration.connection_driver and 
            MonsoonOpenstackAuth.configuration.connection_driver.endpoint
            
            @services = DomainModelServiceLayer::ServicesManager.new(
              MonsoonOpenstackAuth.configuration.connection_driver.endpoint,
              region,
              current_user)
          end
        end
        # if services was first called for admin_identity it can happens that current_user was nil.
        @services.current_user = current_user 
        @services
      end
    end
  end
  
  class ServicesManager
    attr_accessor :current_user
    def initialize(endpoint,region,current_user)
      @endpoint = endpoint
      @region = region
      @current_user = current_user
    end 
    
    # this method is called every time the services.identity or services.volume ect. in controller is requested.
    # See InstanceMethods#services
    def method_missing(method_sym, *arguments, &block)
      # ignore classes
      return true if method_sym == :klass
      
      # load service from cache if available
      service = instance_variable_get("@#{method_sym.to_s}")
      
      # service is not cached yet -> first request
      unless service      
        # construct the class name of requested service.
        # For example ServiceLayer::IdentityService.
        # Services must be located in app/services/openstack
        service_class_name = "ServiceLayer::#{method_sym.to_s.classify}Service"
        
        # load service class
        klazz = begin
          eval(service_class_name)
        rescue
          raise "service #{service_class_name} not found!"
        end

        # service must extend DomainModelServiceLayer::BaseProvider, see below.
        unless klazz < DomainModelServiceLayer::Service
          raise "service #{service_class_name} is not a subclass of DomainModelServiceLayer::BaseProvider"  
        end

        service = klazz.new(@endpoint,@region,@current_user)
        service.services=self
        # new service is instantiated -> cache it for further use in the same controller request.
        instance_variable_set("@#{method_sym.to_s}", service)
      end
      
      return service
    end
  end
  
  class Service
    attr_accessor :services, :driver, :current_user, :auth_url, :region, :token, :domain_id, :project_id
    
    def initialize(auth_url,region,current_user)
      @auth_url     = auth_url
      @region       = region
      @current_user = current_user
      
      if current_user
        @token        = current_user.token
        @domain_id    = current_user.domain_id
        @project_id   = current_user.project_id
      end
      
      # init driver
      init({
        auth_url:   @auth_url,
        region:     @region,
        token:      @token,
        domain_id:  @domain_id,
        project_id: @project_id  
      })
    end
    
    def init(params={})
      raise "Not implemented yet!"
    end 
    
    # TODO: use public url!!!
    def get_service_url(type,version=nil)
      network_service = @current_user.service_catalog.select do |service| 
        service["type"]==type
      end.first
    
      endpoint_url = network_service["endpoints"].select do |endpoint|
        endpoint["region_id"]==@region 
      end.first["url"]
    
      if version.nil?
        endpoint_url
      else
        endpoint_url.last=='/' ? endpoint_url+version : endpoint_url+"/#{version}"
      end
    end
  end
end