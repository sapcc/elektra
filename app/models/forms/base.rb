module Forms
  class Base
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    attr_reader :errors, :model
    
    ERRORS_TO_IGNORE = ["code","title"]
  
    # class methods
    class << self
      
      # create setters and getters based on the wrapped fog class
      def wrapper_for(fog_model_class)
        @fog_model_class = fog_model_class
        
        @attribute_names = @fog_model_class.attributes
        attr_accessor *@attribute_names
      end  
      
      # defines which attributes shouldn't be used
      def ignore_attributes(*names)
        names = names.flatten
        @attribute_names.delete_if {|name| names.include?(name) } 
      end
      
      # defines default values, e.g.: enabled: true 
      def default_values(hash={})
        @default_values=hash
      end
      
      # instead of using wrapper_for it is possible to define manually which attributes to use. 
      def attributes(*names)
        names = names.flatten
        @attribute_names = names
        attr_accessor *names
      end
      
      def attribute_names
        @attribute_names
      end
      
      def get_default_values
        @default_values || {}
      end
    end
    
    def initialize(service, id=nil)
      @service = service
      
      # get just the name of class without namespaces
      @class_name = self.class.name.split('::').last.downcase      
      
      # intialize default values
      self.attributes=self.class.get_default_values

      # create errors object
      @errors = ActiveModel::Errors.new(self)     
      @model = nil
      load_model(id) if id
      
      # execute after callback
      after_initialize
    end
  
    def attributes=(params={})
      params.each do |name, value|
        self.send("#{name}=",value) if self.respond_to?(name.to_sym)
      end
    end
    
    def attributes
      result = {}
      self.class.attribute_names.each {|name| result[name.to_sym] = self.send(name) }
      result 
    end
  
    def save
      # execute before callback
      before_save
      
      success = self.valid?

      if success
        if @model.nil?
          success = create
        else
          success = update
        end
      end
      
      return success & after_save 
    end
    
    def api_error_name_mapping 
      {
        #"message": " ",
        "Message": "message"
      }
    end
    
    def destroy
      # execute before callback
      before_destroy
      
      error_names = api_error_name_mapping
      begin
        if @model
          @model.destroy 
          return true
        else
          name = error_names['message'] || ' '
          
          self.errors.add(name, "Could not destroy #{@class_name}. #{@class_name.capitalize} not found.") 
          return false
        end
      rescue => e
        errors = ::ApiErrorParser.handle(e)
        errors.each do |name, message|
          n = error_names[name] || error_names[message] || name
          message = message.join(", ") if message.is_a?(Array)
          self.errors.add(n, message.to_s) unless ERRORS_TO_IGNORE.include?(name.to_s.downcase)
        end
          
        return false
      end  
    end
    
    protected
    
    # callbacks
    def before_create;    return true;  end
    def before_destroy;   return true;  end
    def before_save;      return true;  end
    def after_initialize; return true;  end
    def after_create;     return true;  end
    def after_save;       return true; end
  
    def create
      # execute before callback
      before_create
      
      create_attributes = self.attributes
      create_attributes.delete(:id)
      
      begin
        @model = @service.send("create_#{@class_name}", create_attributes)
        self.id = @model.id
      rescue => e
        error_names = api_error_name_mapping

        errors = ::ApiErrorParser.handle(e)
        errors.each do |name, message|
          n = error_names[name] || error_names[message] || name
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
      self.class.attribute_names.each do |name| 
        @model.send"#{name}=",self.send(name) unless name.to_sym==:id 
      end
      begin
        @model.save
      rescue => e
        error_names = api_error_name_mapping
        
        errors = ::ApiErrorParser.handle(e)
        errors.each do |name, message|
          n = error_names[name] || error_names[message] || name
          message = message.join(", ") if message.is_a?(Array)
          self.errors.add(n, message.to_s) unless ERRORS_TO_IGNORE.include?(name.to_s.downcase)
        end
        return false
      end
      return true
    end
    
    def load_model(id)
      @model = @service.send("find_#{@class_name}",id)
      self.attributes = @model.attributes
    end
    
  end
end