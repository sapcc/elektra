module Monitoring
  class Dimension < Core::ServiceLayer::Model
    
    # The following properties are known
    # dimension_name
    # values
    
    def name
      read(:dimension_name)
    end

  end
end
