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

      #
      # # CGI.escape, but without special treatment on spaces
      # def self.escape(str, extra_exclude_chars = '')
      #   str.gsub(/([^a-zA-Z0-9_.-#{extra_exclude_chars}]+)/) do
      #     '%' + $1.unpack('H2' * $1.bytesize).join('%').upcase
      #   end
      # end
      #
      # def escape(str, extra_exclude_chars = '')
      #   self.class.escape(str, extra_exclude_chars)
      # end

      def class_map_proc(klass)
        proc { |params| klass.new(self, params) }
      end
    end
  end
end
