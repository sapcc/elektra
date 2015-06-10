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
      if @model.nil?
        create
      else
        update
      end
    end
    
    def destroy
      begin
        if @model
          @model.destroy 
          return true
        else
          self.errors.add(' ', "Could not destroy #{@class_name}. #{@class_name.capitalize} not found.") 
          return false
        end
      rescue => e
        errors = parse_error(e)
        errors.each do |name, message|
          name = ' ' if name.to_s.downcase=='message'
          self.errors.add(name, message) unless ERRORS_TO_IGNORE.include?(name.to_s.downcase)
        end
          
        return false
      end  
    end
    
    protected
  
    def create
      create_attributes = self.attributes
      create_attributes.delete(:id)
      
      begin
        @model = @service.send("create_#{@class_name}", create_attributes)
      rescue => e
        errors = parse_error(e)
        errors.each do |name, message|
          name = ' ' if name.to_s.downcase=='message'
          self.errors.add(name, message) unless ERRORS_TO_IGNORE.include?(name.to_s.downcase)
        end
          
        return false
      end
      self.attributes = @model.attributes
      return true
    end
    
    def update
      self.class.attribute_names.each do |name| 
        @model.send"#{name}=",self.send(name) unless name.to_sym==:id 
      end
      begin
        @model.save
      rescue => e
        errors = parse_error(e)
        errors.each do |name, message|
          self.errors.add(name, message) unless ERRORS_TO_IGNORE.include?(name.to_s.downcase)
        end
        return false
      end
      return true
    end
    
    def load_model(id)
      @model = @service.send("find_#{@class_name}",id)
      self.attributes = @model.attributes
    end
  
    def parse_error(e)
      puts e     
      if e.class.name.starts_with?("Fog::")
        return {@class_name => e.message}
      end

      begin
        errors = e.message.scan(/.*excon\.error\.response.*\n.*:body\s*=>\s*"(.*).*"\n/)
        error_string = errors.flatten.first
        error_string.gsub!(/\\+"/,'"') if error_string
        parsed_errors = JSON.parse(error_string)
        parsed_errors["errors"] || parsed_errors["error"]
      rescue
        return {"Error" => e.message}
      end
    end
    
  end
end