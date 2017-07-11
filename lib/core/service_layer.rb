require_relative 'service_layer/driver/base'
require_relative 'service_layer/fog_driver/client_helper'
require_relative 'service_layer/misty_driver/client_helper'
require_relative 'service_layer/errors'
require_relative 'service_layer/api_error_handler'
require_relative 'service_layer/model'

module Core
  # implements service layer
  module ServiceLayer

    class ServicesManager
      attr_accessor :current_user,:service_user

      class << self
        # create a service for given params
        def service(service_name,params={})
          # construct the class name of requested service.
          # For example ServiceLayer::IdentityService.
          # Services must be located in app/services/service_layer
          service_class_name = service_name.to_s.classify
          # if service_name contains a "s" at the end then add a s to the class_name
          service_class_name += 's' if service_name.to_s.last=='s'
          # build the complete class name
          service_class_name = "::ServiceLayer::#{service_class_name}Service"

          # try to evaluate the class
          klazz = begin
            eval(service_class_name)
          rescue
            raise "service #{service_class_name} not found!"
          end

          # raise an error unless the class inherits from Service
          unless klazz < Core::ServiceLayer::Service
            raise "service #{service_class_name} is not a subclass of Core::ServiceLayer::BaseProvider"
          end

          # create an instance of the service class
          if klazz
            klazz.new(
              Core.keystone_auth_endpoint(params[:auth_url]),
              params.delete(:region),
              params.delete(:token),
              params
            )
          end
        end
      end

      def initialize(region)
        @region = region
      end

      def available?(service_name,action_name=nil)

        begin
          self.send(service_name.to_sym).send(:available?,(action_name.nil? ? nil : action_name.to_sym))
        rescue
          false
        end
      end

      # this method is called every time the services_ng.identity or services.volume ect. in controller is requested.
      # See InstanceMethods#services
      def method_missing(method_sym, *arguments, &block)
        # ignore classes
        return true if method_sym == :klass

        # load service from cache if available
        service = instance_variable_get("@#{method_sym.to_s}")

        # service is not cached yet -> first request
        unless service
          # create a Core::ServiceLayer::Service
          current_user_identity_url = @current_user.service_url('identity', {region: @region, interface: 'public'}) rescue nil
          params = {
            auth_url: Core.keystone_auth_endpoint(current_user_identity_url),
            region: @region,
          }
          if @current_user
            params[:token]      = @current_user.token
            params[:domain_id]  = @current_user.domain_id
            params[:project_id] = @current_user.project_id
          end

          service = self.class.service(method_sym,params)
          service.services=self
          service.current_user = @current_user
          service.service_user = @service_user
          # new service is instantiated -> cache it for further use in the same controller request.
          instance_variable_set("@#{method_sym.to_s}", service)
        end

        return service
      end
    end

    # Service class
    # each service in app/services/service_layer should inherit from this class.
    # It provides the context of current user
    class Service
      attr_accessor :services, :current_user, :service_user
      attr_reader :auth_url, :region, :token, :domain_id, :project_id, :service_catalog

      def initialize(auth_url,region,token, options={})
        @region           = region
        @auth_url         = auth_url
        @token            = token

        @domain_id        = options[:domain_id]
        @project_id       = options[:project_id]
        @service_catalog  = options[:service_catalog] || []
      end

      def available?(action_name_sym=nil)
        false
      end

      def service_url(type, options={})
        region = options[:region] || @region
        interface = options[:interface] || 'public'

        service = service_catalog.select do |service|
          service["type"]==type.to_s
        end.first

        return nil unless service

        endpoint = service["endpoints"].select do |endpoint|
          endpoint["region_id"]==region.to_s and endpoint["interface"]==interface.to_s
        end.first

        return nil unless endpoint

        endpoint["url"]
      end
    end
  end
end
