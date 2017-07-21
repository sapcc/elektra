# frozen_string_literal: true

module Core
  module Api
    # Wrapper for API errors
    class Error < StandardError
      attr_reader :response, :messages, :code, :code_type, :error_type

      def initialize(response)
        if response
          @code = response.code.try(:to_i)
          @code_type = code_type
          @error_type = error_type

          @response = response
          data = @response.respond_to?(:body) ? @response.body : @response
          unless data.is_a?(Hash)
            data = begin
                     JSON.parse(data)
                   rescue
                     data
                   end
          end

          @messages = Error.read_error_messages(data)
          super(@messages.join(', '))
        else
          super(response)
        end
      end

      def self.read_error_messages(hash,messages=[])
        return [hash.to_s] unless hash.respond_to?(:each)
        hash.each do |k, v|
          messages << v if %w[message type].include?(k)
          if v.is_a?(Hash)
            read_error_messages(v, messages)
          elsif v.is_a?(Array)
            v.each do |value|
              read_error_messages(value, messages) if value.is_a?(Hash)
            end
          end
        end
        messages
      end
    end
  end
end
