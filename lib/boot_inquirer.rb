require 'logger'

class BootInquirer
  class << self  
    def logger  
      @logger ||= Logger.new(STDOUT)
    end
    
    def load_apps(filter={},&block)
      only = filter[:only] 
      except = filter[:except] || []
      except.delete('core')

      @available_apps = []
      
      all_apps_paths.each do |app_path| 
        app_name = app_path.gsub("#{apps_path}/",'')
        do_load = false
        
        if only 
          only << 'core'
          do_load = true if only.include?(app_name)
        else
          do_load = true unless except.include?(app_name)
        end
        
        if do_load
          block.call(app_path) if block_given?
          @available_apps << App.new(app_path,app_name) 
        end
      end
    end
    
    def app_available?(app_name)
      !get_app(app_name).nil?
    end
        
    def apps_path
      @apps_path ||= 'apps'
    end
    
    def apps_path=(new_path)
      @apps_path=new_path
    end
        
    def available_apps
      @available_apps ||= load_apps
    end
    
    def get_app(name)
      @available_apps.find{|app|app.name==name}
    end
    
    def all_apps_paths
      Dir.glob("#{apps_path}/*")
    end
  end
  
  class App
    attr_reader :path, :name
    def initialize(path,name)
      @path = path
      @name = name
    end
    
    def engine_class
      unless @engine_class
        engine_name = @name.capitalize
        @engine_class = engine_name.constantize.const_get(:Engine) rescue nil
      end
      @engine_class
    end
    
    def engine?
      !engine_class.nil?
    end
    
    def mountable?
      engine?
    end
  end
end