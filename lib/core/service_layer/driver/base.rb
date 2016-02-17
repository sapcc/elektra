module Core
  module ServiceLayer
    module Driver
      # this class maps the response to a given container class
      # e.g. list_domains -> [Indentity::Domain], get_domain -> Indentity::Domain 
      class Mapper
        def initialize(driver,klass)
          @driver=driver
          @klass=klass
        end
      
        def map(response)
          if response.is_a?(Array)
            response.collect{|attributes| @klass.new(@driver,attributes)}
          else
            @klass.new(@driver,response)
          end
        end
      
        def method_missing(method_sym, *arguments, &block)     
          if arguments.count>0
            map(@driver.send(method_sym, *arguments, &block))
          else
            map(@driver.send(method_sym,&block))
          end
        end
      end
    
      # Base Driver Class
      # TODO catch other errors (depending on driver)
      class Base
        def initialize(params={})
          @auth_url   = params[:auth_url]
          @region     = params[:region]
          @token      = params[:token]
          @domain_id  = params[:domain_id]
          @project_id = params[:project_id]        
        end 
      
        def handle_response(&block)
          response = block.call
          return nil unless response

          response
        rescue => e
          raise Core::ServiceLayer::Errors::ApiError.new(e)
        end
      
        # use a mapper for response
        def map_to(klass)
          unless (klass<=Core::ServiceLayer::Model)
            raise Core::ServiceLayer::Errors::BadMapperClass.new("#{klass} is not a subclass of Core::ServiceLayer::Model")
          end
          Mapper.new(self,klass)
        end 
      end 
    end
  end
end