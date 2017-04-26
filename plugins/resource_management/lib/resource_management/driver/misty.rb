require 'misty/openstack/limes'

# FIXME: check error handling for 404, 500 or 401

module ResourceManagement
  module Driver
    class Misty < Interface
      include Core::ServiceLayer::MistyDriver::ClientHelper

      def initialize(params_or_driver)
        super(params_or_driver)
      end

      def get_project_data(domain_id, project_id=nil, options={})
        query = prepare_filter(options)

        response = handle_response do
          expect(Net::HTTPOK) do
            if project_id.nil?
              if query.empty?
                misty.resources.get_projects(domain_id)
              else
                misty.resources.get_projects(domain_id, query)
              end
            else
              if query.empty?
                misty.resources.get_project(domain_id, project_id)
              else
                misty.resources.get_project(domain_id, project_id, query)
              end
            end
          end
        end

        response.body[project_id.nil? ? 'projects' : 'project']
      end

      def get_domain_data(domain_id=nil, options={})
        query = prepare_filter(options)

        response = handle_response do
          expect(Net::HTTPOK) do
            if domain_id.nil?
              if query.empty?
                misty.resources.get_domains
              else
                misty.resources.get_domains(query)
              end
            else
              if query.empty?
                misty.resources.get_domain(domain_id)
              else
                misty.resources.get_domain(domain_id,query)
              end
            end
          end
        end

        response.body[domain_id.nil? ? 'domains' : 'domain']
      end

      def get_cluster_data(options={})
        query = prepare_filter(options)

        response = handle_response do
          expect(Net::HTTPOK) do
            if query.empty?
              misty.resources.get_current_cluster
            else
              misty.resources.get_current_cluster(query)
            end
          end
        end

        response.body['cluster']
      end

      def put_project_data(domain_id, project_id, services)
        handle_response do
          expect(Net::HTTPOK) do
            misty.resources.set_quota_for_project(domain_id,project_id, :project => {:services => services})
          end
        end
      end

      def put_domain_data(domain_id, services)
        handle_response do
          expect(Net::HTTPOK) do
            misty.resources.set_quota_for_domain(domain_id, :domain => {:services => services})
          end
        end
      end

      def put_cluster_data(services)
        handle_response do
          expect(Net::HTTPOK) do
            misty.resources.set_capacity_for_current_cluster(:cluster => {:services => services})
          end
        end
      end

      def sync_project_asynchronously(domain_id, project_id)
        handle_response do
          expect(Net::HTTPAccepted) do
            misty.resources.sync_project(domain_id, project_id)
          end
        end
        return nil
      end

      private

      def prepare_filter(options)
        query = {
          service:  options[:services],
          resource: options[:resources],
        }.reject { |_,v| v.nil? }
        return Excon::Utils.query_string(query: query).sub(/^\?/, '')
      end

      ##########################################################################
      # error handling
      #
      # Misty does not do any error handling by itself. It returns a
      # Net::HTTPResponse instance, or rather, an instance of a subclass of
      # Net::HTTPResponse. The concrete subclass indicates the HTTP status code
      # in the response, e.g. 401 responses will be instances of
      # Net::HTTPUnauthorized.
      #
      # expect() wraps responses with unexpected status codes into a custom
      # exception class (see below) and raises the exception, so that Elektra's
      # regular error handling can commence.

      def expect(*classes)
        response = yield
        raise BackendError.new(response) unless classes.include?(response.class)
        return response
      end

      class BackendError < ::StandardError
        attr_reader :response

        def initialize(response)
          @response = response

          # make @response behave more like an Excon error
          def @response.get_header(key)
            get_fields(key).first
          end
        end

        def error_name
          # mimics Fog-like status-specific error class names (one per status code)
          # e.g. "Not Found" -> "NotFound"
          @response.message.gsub(' ', '')
        end

        def to_str
          @response.body.to_s
        end
      end

    end
  end
end
