# frozen_string_literal: true

require_relative '../strip_attributes'

module Core
  module ServiceLayer
    # Describes the Openstack Model
    class Model
      class MissingAttributeError < StandardError; end

      extend ActiveModel::Naming
      extend ActiveModel::Translation
      include ActiveModel::Conversion
      include ActiveModel::Validations
      include Core::StripAttributes
      include ActiveModel::Validations::Callbacks

      strip_attributes

      attr_reader :errors, :service
      attr_accessor :id

      def initialize(service, params = nil)
        @service = service
        # get just the name of class without namespaces
        @class_name = self.class.name.split('::').last.underscore
        self.attributes = params || {}
        # create errors object
        @errors = ActiveModel::Errors.new(self)
        # execute after callback
        after_initialize
      end

      def inspect
        attributes.to_s
      end

      def attributes
        @attributes.merge(id: @id)
      end

      def as_json(_options = nil)
        attributes.each_with_object({}) do |(k,v),hash|
          hash[k] = sanitize(v)
        end
      end

      # look in attributes if a method is missing
      def method_missing(method_sym, *arguments, &block)
        attribute_name = method_sym.to_s
        attribute_name = attribute_name.chop if attribute_name.ends_with?('=')

        if arguments.count > 1
          write(attribute_name, arguments)
        elsif arguments.count.positive?
          write(attribute_name, arguments.first)
        else
          sanitize(read(attribute_name))
        end
      end

      def respond_to?(method_name, include_private = false)
        keys = @attributes.keys
        method_name.to_s == 'id' ||
          keys.include?(method_name.to_s) ||
          keys.include?(method_name.to_sym) ||
          super
      end

      def requires(*attrs)
        attrs.each do |attr|
          if send(attr.to_s).nil?
            raise MissingAttributeError, "#{attr} is missing"
          end
        end
      end

      def save
        # execute before callback
        before_create if id.nil?
        before_save

        success = valid?

        if success
          success = id.nil? ? perform_create : perform_update
        end
        success & after_save
      end

      def update(attributes = {})
        return false unless attributes
        action_controller_params_to_hash(attributes.clone).each do |key, value|
          send("#{key}=", value)
        end
        save
      end

      alias_method :update_attributes, :update

      def destroy
        requires :id

        # execute before callback
        before_destroy

        rescue_api_errors do
          perform_service_delete(id)
          return true
        end
      end

      def attributes=(new_attributes)
        new_attributes = new_attributes.blank? ? {} : new_attributes.clone
        @attributes = action_controller_params_to_hash(new_attributes)
        # delete id from attributes!
        new_id = (@attributes.delete('id') || @attributes.delete(:id))
        # if current_id is nil then overwrite it with new_id.
        @id = new_id if @id.nil? || (@id.is_a?(String) && @id.empty?)
        @attributes
      end

      def sanitize(value)
        return value unless value.is_a?(String)
        @full_sanitizer ||= Rails::Html::FullSanitizer.new
        @full_sanitizer.sanitize(value)
      end

      def action_controller_params_to_hash(params)
        if params.is_a?(ActionController::Parameters)
          params = params.to_unsafe_hash
        end
        if params.is_a?(Hash)
          params = params.with_indifferent_access
          params.each do |k, v|
            params[k] = action_controller_params_to_hash(v)
          end
        end
        params
      end

      def escape_attributes!
        escaped_attributes = (@attributes || {}).clone
        escaped_attributes.each { |k, v| @attributes[k] = escape_value(v) }
      end

      # callbacks
      def before_create
        true
      end

      def before_destroy
        true
      end

      def before_save
        true
      end

      def after_initialize
        true
      end

      def after_create
        true
      end

      def after_save
        true
      end

      def created_at
        value = read('created') || read('created_at')
        DateTime.parse(value) if value
      end

      def pretty_created_at
        Core::Formatter.format_modification_time(created_at) if created_at
      end

      def updated_at
        value = read('updated') || read('updated_at')
        DateTime.parse(value) if value
      end

      def pretty_updated_at
        Core::Formatter.format_modification_time(updated_at) if updated_at
      end

      def attributes_for_create
        @attributes
      end

      def attributes_for_update
        @attributes
      end

      def write(attribute_name, value)
        @attributes[attribute_name.to_s] = value
      end

      def read(attribute_name)
        value = @attributes[attribute_name.to_s]
        value = @attributes[attribute_name.to_sym] if value.nil?
        value
      end

      def escape_value(value)
        value = CGI.escapeHTML(value) if value.is_a?(String)
        value
      end

      def pretty_attributes
        JSON.pretty_generate(@attributes.merge(id: id))
      end

      def to_s
        pretty_attributes
      end

      def attribute_to_object(attribute_name, klass)
        value = read(attribute_name)

        return nil unless value
        @service.map_to(klass, value)
      end

      protected

      def perform_create
        rescue_api_errors do
          # execute before callback
          create_attrs = attributes_for_create
          create_attrs.delete(:id)
          created_attributes = perform_service_create(create_attrs)
          self.attributes = created_attributes
        end
      end

      def perform_update
        rescue_api_errors do
          update_attrs = attributes_for_update
          update_attrs.delete(:id)
          updated_attributes = perform_service_update(id, update_attrs)
          self.attributes = updated_attributes if updated_attributes
        end
      end

      # map to service create method
      def perform_service_create(create_attributes)
        @service.send("create_#{@class_name}", create_attributes)
      end

      # map to service update method
      def perform_service_update(id, update_attributes)
        @service.send("update_#{@class_name}", id, update_attributes)
      end

      # map to service delete method
      def perform_service_delete(id)
        @service.send("delete_#{@class_name}", id)
      end

      # handle api errors
      def rescue_api_errors
        yield
        true
      rescue ::Elektron::Errors::ApiResponse => e
        # "API Error happened :-(" 
        e.messages.each { |m| errors.add(:api, m) unless m.blank?}
        false
      end
    end
  end
end
