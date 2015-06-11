# provides openstack services in controller and views
module OpenstackServiceProvider
  
  # this module is included in controllers
  module Services
    def self.included(base)
      base.send :include, InstanceMethods
      base.send :helper_method, :services
    end

    module InstanceMethods
      # load services provider
      def services(region=nil)
        unless @services
          region ||= auth_session.region if auth_session
          region ||= MonsoonOpenstackAuth.configuration.default_region
          
          if MonsoonOpenstackAuth.configuration.connection_driver and 
            MonsoonOpenstackAuth.configuration.connection_driver.endpoint
            
            @services = OpenstackServiceProvider::ServicesManager.new(
              MonsoonOpenstackAuth.configuration.connection_driver.endpoint,
              region,
              current_user)
          end
        end
        @services
      end
    end
  end
  
  class ServicesManager
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
        # For example Openstack::IdentityService.
        # Services must be located in app/services/openstack
        service_class_name = "Openstack::#{method_sym.to_s.classify}Service"
        
        # load service class
        klazz = begin
          eval(service_class_name)
        rescue
          raise "service #{service_class_name} not found!"
        end

        # service must extend OpenstackServiceProvider::BaseProvider, see below.
        unless klazz < OpenstackServiceProvider::BaseProvider
          raise "service #{service_class_name} is not a subclass of OpenstackServiceProvider::BaseProvider"  
        end

        service = klazz.new(@endpoint,@region,@current_user)
        service.services=self
        # new service is instantiated -> cache it for further use in the same controller request.
        instance_variable_set("@#{method_sym.to_s}", service)
      end
      
      return service
    end
  end
  
  class BaseProvider
    attr_accessor :services
    def initialize(endpoint,region,current_user)
      @endpoint = endpoint
      @region = region
      @current_user = current_user
    end
  end
  
  class FogProvider < BaseProvider
    def initialize(endpoint,region,current_user)
      super

      @auth_params = {
        provider: 'openstack',
        openstack_auth_token: @current_user.token,
        openstack_auth_url: @endpoint,
        openstack_region: @region
      }
      
      @auth_params[:openstack_domain_id]=current_user.domain_id if current_user.domain_id
      @auth_params[:openstack_project_id]=current_user.project_id if current_user.project_id

      @driver = driver(@auth_params)
    end
    
    def driver(auth_params)
      raise "Not implemented yet!"
    end
    
    def method_missing(method_sym, *arguments, &block)
      if arguments.blank?
        @driver.send(method_sym)
      else
        @driver.send(method_sym, arguments)
      end
    end
  end
  
end