module Core
  module ServiceLayer
    class Model
      extend ActiveModel::Naming
      extend ActiveModel::Translation
      include ActiveModel::Conversion
      include ActiveModel::Validations

      attr_reader :errors, :attributes

      ERRORS_TO_IGNORE = ["code", "title"]

      def initialize(driver, params=nil)
        @driver = driver
        self.attributes=params
        # get just the name of class without namespaces
        @class_name = self.class.name.split('::').last.underscore

        # create errors object
        @errors = ActiveModel::Errors.new(self)

        # execute after callback
        after_initialize
      end

      def id
        @id
      end

      # look in attributes if a method is missing  
      def method_missing(method_sym, *arguments, &block)
        attribute_name = method_sym.to_s
        attribute_name = attribute_name.chop if attribute_name.ends_with?('=')

        if arguments.count>1
          write(attribute_name, arguments)
        elsif arguments.count>0
          write(attribute_name, arguments.first)
        else
          read(attribute_name)
        end
      end

      def respond_to?(method_name, include_private = false)
        keys = @attributes.keys
        method_name.to_s=="id" or keys.include?(method_name.to_s) or keys.include?(method_name.to_sym) or super
      end

      def requires(*attrs)
        attrs.each do |attribute|
          if self.send(attribute.to_s).nil?
            raise Core::ServiceLayer::Errors::MissingAttribute.new("#{attribute} is missing")
          end
        end
      end

      def api_error_name_mapping
        {
            #"message": " ",
            "Message": "message"
        }
      end

      def save
        # execute before callback
        before_save

        success = self.valid?

        if success
          if self.id.nil?
            success = perform_create
          else
            success = perform_update
          end
        end

        return success & after_save
      end

      def update(attributes={})
        attributes.each do |key, value|
          send("#{key.to_s}=", value)
        end
        return save
      end

      alias_method :update_attributes, :update

      def destroy
        requires :id
        # execute before callback
        before_destroy

        error_names = api_error_name_mapping
        begin
          if id
            @driver.send("delete_#{@class_name}", id)
            return true
          else
            name = error_names['message'] || ' '

            self.errors.add(name, "Could not destroy #{@class_name}. Id not presented.")
            return false
          end
        rescue => e
          raise e unless @driver.handle_api_errors?
          errors = Core::ServiceLayer::ApiErrorHandler.parse(e)
          errors.each do |name, message|
            n = error_names[name] || error_names[message] || name || ' '
            message = message.join(", ") if message.is_a?(Array)
            self.errors.add(n, message.to_s) unless ERRORS_TO_IGNORE.include?(name.to_s.downcase)
          end

          return false
        end
      end

      def attributes=(new_attributes)
        @attributes = (new_attributes || {}).clone
        # delete id from attributes!
        new_id = nil
        if @attributes["id"] or @attributes[:id]
          new_id = (@attributes.delete("id") or @attributes.delete(:id))
        end
        # if current_id is nil then overwrite it with new_id.
        @id ||= new_id
      end

      # callbacks
      def before_create;
        return true;
      end

      def before_destroy;
        return true;
      end

      def before_save;
        return true;
      end

      def after_initialize;
        return true;
      end

      def after_create;
        return true;
      end

      def after_save;
        return true;
      end

      def created_at
        value = read("created") || read("created_at")
        Time.parse(value) if value
      end

      def updated_at
        value = read("updated") || read("updated_at")
        Time.parse(value) if value
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
        @attributes[attribute_name.to_s] || @attributes[attribute_name.to_sym]
      end

      def pretty_attributes
        JSON.pretty_generate(@attributes.merge(id: self.id))
      end

      def to_s
        pretty_attributes
      end

      def attribute_to_object(attribute_name, klass)
        value = read(attribute_name)

        if value
          if value.is_a?(Hash)
            return klass.new(@driver, value)
          elsif value.is_a?(Array)
            return value.collect { |attrs| klass.new(@driver, attrs) }
          end
        end
        return nil
      end

      protected

      def perform_create
        # execute before callback
        before_create

        create_attrs = self.attributes_for_create.with_indifferent_access
        create_attrs.delete(:id)

        begin
          created_attributes = @driver.send("create_#{@class_name}", create_attrs)
          self.attributes= created_attributes
        rescue => e
          raise e unless defined?(@driver.handle_api_errors?) and @driver.handle_api_errors?

          error_names = api_error_name_mapping

          errors = Core::ServiceLayer::ApiErrorHandler.parse(e)
          errors.each do |name, message|
            n = error_names[name] || error_names[message] || name || 'message'
            message = message.join(", ") if message.is_a?(Array)
            self.errors.add(n, message.to_s) unless ERRORS_TO_IGNORE.include?(name.to_s.downcase)
          end

          return false
        end
        #self.attributes = @model.attributes
        after_create
        return true
      end

      def perform_update
        begin
          update_attrs = attributes_for_update.with_indifferent_access
          update_attrs.delete(:id)
          updated_attributes = @driver.send("update_#{@class_name}", id, update_attrs)
          self.attributes=updated_attributes if updated_attributes
        rescue => e
          raise e unless defined?(@driver.handle_api_errors?) and @driver.handle_api_errors?

          error_names = api_error_name_mapping

          errors = Core::ServiceLayer::ApiErrorHandler.parse(e)
          errors.each do |name, message|
            n = error_names[name] || error_names[message] || name || ' '
            message = message.join(", ") if message.is_a?(Array)
            self.errors.add(n, message.to_s) unless ERRORS_TO_IGNORE.include?(name.to_s.downcase)
          end
          return false
        end
        return true
      end

    end
  end
end
