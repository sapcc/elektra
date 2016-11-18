module Core
  module ServiceUser
    module Errors
      class AuthenticationError < StandardError
        def message
          super.gsub('(Disable insecure_debug mode to suppress these details.)','')
        end  
      end
      
    end
  end
end