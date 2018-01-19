# frozen_string_literal: true

module Core
  module ServiceLayerNg
    # Service class
    # each service in app/services/service_layer should inherit from this class.
    # It provides the context of current user
    class Service
      attr_accessor :service_manager
      attr_reader :elektron, :region

      def initialize(elektron)
        @elektron = elektron
        @region = Rails.configuration.default_region
      end

      def available?(_action_name_sym = nil)
        false
      end

      ############################ OBSOLETE ############################
      # TODO: remove this code after all dependencies to misty are removed!
      def api
        @api ||= ::Core::Api::ClientWrapper.new(misty_client, self)
      end

      def misty_client
        @misty_client ||= create_misty_client
      end

      def create_misty_client
        options = {
          region_id:       Rails.configuration.default_region,
          ssl_verify_mode: Rails.configuration.ssl_verify_peer,
          interface:       ENV['DEFAULT_SERVICE_INTERFACE'] || 'internal',
          log_level:       Logger::INFO,
          keep_alive_timeout: 5,
          #headers: { "Accept-Encoding" => "" },

          # compute: {:version => '2.9'}, ...waiting for backend support

          # needed because of wrong urls in service catalog.
          # The identity url contains a /v3. This leads to a wrong url in misty!
          identity: { base_path: '/' },
          resources: { interface: 'public' },
          database: { interface: 'public' },
          metrics: { interface: 'public' },
          masterdata:  { interface: 'public' },
          shared_file_systems: { service_name: 'sharev2' }
        }
        @elektron.enforce_valid_token

        ::Misty::Cloud.new(
          {
            auth: {
              context: {
                catalog: @elektron.catalog,
                expires: @elektron.expires_at.to_s,
                token: @elektron.token
              }
            },
          }.merge(options)
        )
      end

      # This method is used to map raw data to a Object.
      def self.map_to(klazz, data, options = {}, &block)
        if data.is_a?(Array)
          data.collect do |item|
            create_map_object(klazz, item.merge(options), &block)
          end
        elsif data.is_a?(Hash)
          create_map_object(klazz, data.merge(options), &block)
        elsif data.is_a?(ActionController::Parameters)
          create_map_object(klazz, data.to_unsafe_hash.merge(options), &block)
        else
          data
        end
      end

      def map_to(klass, data, options = {})
        if data.is_a?(Array)
          data.collect do |item|
            klass.send(:new, self, (item || {}).merge(options))
          end
        elsif data.is_a?(Hash)
          klass.send(:new, self, data.merge(options))
        elsif data.is_a?(ActionController::Parameters)
          klass.send(:new, self, data.to_unsafe_hash.merge(options))
        else
          data
        end
      end

      ####################### END OBSOLETE #######################

      # CGI.escape, but without special treatment on spaces
      def self.escape(str, extra_exclude_chars = '')
        str.gsub(/([^a-zA-Z0-9_.-#{extra_exclude_chars}]+)/) do
          '%' + $1.unpack('H2' * $1.bytesize).join('%').upcase
        end
      end

      def escape(str, extra_exclude_chars = '')
        self.class.escape(str, extra_exclude_chars)
      end

      def class_map_proc(klass)
        proc { |params| klass.new(self, params) }
      end
    end
  end
end
