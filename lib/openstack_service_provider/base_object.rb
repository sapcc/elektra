module OpenstackServiceProvider
  class BaseObject
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations
  
    attr_reader :errors, :service
    attr_accessor :attributes
    
    ERRORS_TO_IGNORE = ["code","title"]
    
    def initialize(driver, params=nil)
      @driver = driver
    
      # intialize attributes hash
      @attributes = params.nil? ? {} : params

      # get just the name of class without namespaces
      @class_name = self.class.name.split('::').last.underscore      

      # create errors object
      @errors = ActiveModel::Errors.new(self)     
        
      # execute after callback
      after_initialize      
    end

    # look in attributes if a method is missing  
    def method_missing(method_sym, *arguments, &block)      
      attribute_name = method_sym.to_s
      attribute_name = attribute_name.chop if attribute_name.ends_with?('=')
      
      if arguments.count>1
        write(attribute_name,arguments)
      elsif arguments.count>0
        write(attribute_name,arguments.first)
      else
        read(attribute_name)
      end
    end
    
    def respond_to?(method_name, include_private = false)
      keys = @attributes.keys
      keys.include?(method_name.to_s) or keys.include?(method_name.to_sym) or super
    end
    
    def requires(*attrs)
      attrs.each{|attribute| raise MissingAttribute.new("#{attribute} is missing") unless read(attribute)}
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
        if read("id").nil?
          success = create
        else
          success = update
        end
      end

      return success & after_save
    end
  
    def create
      # execute before callback
      before_create

      create_attrs = self.create_attributes
      create_attrs.delete(:id)

      begin
        @attributes = @driver.send("create_#{@class_name}", create_attrs)
      rescue => e
        error_names = api_error_name_mapping

        errors = handle_api_error(e)
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

    def update
      begin
        updated_attributes = @driver.send("update_#{@class_name}",update_attributes)
        @attributes=update_attributes if update_attributes
      rescue => e
        error_names = api_error_name_mapping

        errors = handle_api_error(e)
        errors.each do |name, message|
          n = error_names[name] || error_names[message] || name || ' '
          message = message.join(", ") if message.is_a?(Array)
          self.errors.add(n, message.to_s) unless ERRORS_TO_IGNORE.include?(name.to_s.downcase)
        end
        return false
      end
      return true
    end
    
    def destroy
      # execute before callback
      before_destroy

      error_names = api_error_name_mapping
      begin
        id = read("id")
        if id
          @driver.send("delete_#{@class_name}",id)
          return true
        else
          name = error_names['message'] || ' '

          self.errors.add(name, "Could not destroy #{@class_name}. Id not presented.")
          return false
        end
      rescue => e
        errors = handle_api_error(e)
        errors.each do |name, message|
          n = error_names[name] || error_names[message] || name || ' '
          message = message.join(", ") if message.is_a?(Array)
          self.errors.add(n, message.to_s) unless ERRORS_TO_IGNORE.include?(name.to_s.downcase)
        end

        return false
      end
    end

    # callbacks
    def before_create;    return true;  end
    def before_destroy;   return true;  end
    def before_save;      return true;  end
    def after_initialize; return true;  end
    def after_create;     return true;  end
    def after_save;       return true; end
    
    def created_at
      value = read("created") || read("created_at")
      Time.parse(value) if value
    end
    
    def updated_at
      value = read("updated") || read("updated_at")
      Time.parse(value) if value
    end
    
    def create_attributes
      @attributes
    end
    
    def update_attributes
      @attributes
    end
  
    def attribute_to_object(attribute_name,klass)
      value = read(attribute_name)
      if value
        if value.is_a?(Hash)
          return klass.new(@driver,value)
        elsif value.is_a?(Array)
          return value.collect{|attrs| klass.new(@driver,attrs)}
        end
      end
    end
  
    def write(attribute_name,value)
      @attributes[attribute_name.to_s] = value
    end
  
    def read(attribute_name)
      @attributes[attribute_name.to_s] || @attributes[attribute_name.to_sym]
    end
    
    def pretty_attributes
      JSON.pretty_generate(@attributes)
    end
    
    def handle_api_error(e)
      result = {@class_name => e.message}

      begin
        #TODO: improove error parsing
        error_message = e.message.gsub('(Disable debug mode to suppress these details.)','')
        errors = error_message.scan(/.*excon\.error\.response.*\n.*:body\s*=>\s*"(.*).*"\n/)

        error_string = errors.flatten.first
        error_string.gsub!(/\\+"/,'"') if error_string
        parsed_errors = JSON.parse(error_string) rescue nil
        result = parsed_errors["errors"] || parsed_errors["error"] if parsed_errors
        result = parsed_errors if result.nil? and parsed_errors.is_a?(Hash)
        result = {"Error" => e.message} unless result
        p ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>ERROR"
        p result
      rescue => e
        puts e
      end

      return result
    end

  end
end