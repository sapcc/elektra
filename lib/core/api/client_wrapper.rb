# frozen_string_literal: true

module Core
  module Api
    # Wrapper for Api Client
    class ClientWrapper
      # Wrapper for misty services
      class Service
        # Wrapper for Response
        class Response
          # delegates some methods to origin response
          delegate :message, :value, :msg, :uri, :code, :header, :body,
                   :http_version, :code_type, :error!, :error_type,
                   :[],
                   to: :@origin_response

          attr_reader :origin_response

          def self.ignore_key?(key)
            %w[links previous next].include?(key) || key.end_with?('_links')
          end

          # This method extracts the mapping key and class from params
          # and returns the class and data
          def self.extract_class_and_data(klazz_or_map, response_body)
            if klazz_or_map.is_a?(Hash) && klazz_or_map.keys.length.positive?
              key = klazz_or_map.keys.first
              if key=='response_body' || key==:response_body
                [klazz_or_map[key], response_body]
              else
                [klazz_or_map[key], response_body[key.to_s]]
              end
            else
              key = response_body.keys.reject { |k| ignore_key?(k) }.first
              [klazz_or_map, response_body[key]]
            end
          end

          def initialize(response, elektra_service = nil)
            @origin_response = response
            @elektra_service = elektra_service
          end

          def data(key = nil)
            key ||= @origin_response.body.keys.reject do |k|
              self.class.ignore_key?(k)
            end.first
            @origin_response.body[key]
          end

          # This method is used to map raw data to a Object.
          def map_to(klazz_or_map, options = {})
            klazz, data = self.class.extract_class_and_data(
              klazz_or_map,
              @origin_response.body
            )

            if @elektra_service.try(:respond_to?, :map_to)
              @elektra_service.map_to(klazz, data, options)
            else
              self.class.map_to(klazz, data, options)
            end
          end

          def self.create_map_object(klazz, params = {}, &block)
            obj = klazz.new(params)
            block.call(obj) if block_given?
            obj
          end

          # This method is used to map raw data to a Object.
          def self.map_to(klazz, data, options = {}, &block)
            if data.is_a?(Array)
              data.collect do |item|
                create_map_object(klazz, item.merge(options), &block)
              end
            elsif data.is_a?(Hash)
              create_map_object(klazz, data.merge(options), &block)
            else
              data
            end
          end
        end

        # SERVICE
        def initialize(service, elektra_service)
          @origin_service = service
          @elektra_service = elektra_service
          # define missing methods for requests and
          # delegate them to api_service

          service.requests.each do |meth|
            next if !meth.is_a?(Symbol) && !meth.is_a?(String)

            (class << self; self; end).class_eval do
              define_method meth do |*args|
                handle_response do
                  begin
                    Rails.logger.debug  "[client-wrapper] -> initialize -> service #{service.class} -> #{meth}(#{args})"
                    service.send(meth, *args)
                  rescue => e
                    raise ::Core::Api::ResponseError, e
                  end
                end
              end
            end
          end
        end
        
        # alternative implementation if "service.requests" is not working properly
        # def method_missing(meth, *args, &block)
        #   (class << self; self; end).class_eval do
        #     define_method meth do |*meth_args| 
        #       handle_response do
        #         begin
        #           Rails.logger.debug  "[client-wrapper] -> initialize -> service #{@origin_service.class} -> #{meth}(#{meth_args})"
        #           @origin_service.send(meth, *meth_args)
        #         rescue => e
        #            raise ::Core::Api::ResponseError, e
        #         end
        #       end
        #     end
        #    end
        #   self.send(meth,*args)
        # end

        def requests
          @origin_service.requests
        end
      
        def uri
          # this is used in object storage to build the url for public access
          @origin_service.instance_variable_get(:@uri).to_s
        end

        # Check for response errors
        def handle_response
          response = yield
          raise ::Core::Api::Error, response if response.code.to_i >= 400
          Response.new(response, @elektra_service)
        end
      end

      # CLIENT WRAPPER
      def catalog
        @api_client.auth.catalog
      end

      def token
        @api_client.auth.token
      end

      def catalog_include_service?(name, region = nil)
        service = catalog.find do |s|
          [s['name'], s['type']].include?(name)
        end

        return service.present? unless region
        service['endpoints'].select { |e| e['region'] == region }.size.positive?
      end

      def initialize(api_client, elektra_service)
        @api_client = api_client
        # create class methods for each service.
        # identity, compute, networking ....
        Misty.services.collect(&:name).each do |name|
          (class << self; self; end).class_eval do
            define_method name do |*_args|
              # cache services in class variables.
              # The api_client is globaly available. The service
              # only defines the proxy methods. Inside this methods
              # the global api_client is called.
              if instance_variable_get("@service_#{name}")
                return instance_variable_get("@service_#{name}")
              end

              begin
                instance_variable_set("@service_#{name}",
                                      Service.new(api_client.send(name),
                                                  elektra_service))
              rescue  JSON::ParserError => e
                raise ::Core::Api::ResponseError, e
              end
            end
          end
        end
      end
    end
  end
end
