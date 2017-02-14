module Monitoring
  class Dimension < Core::ServiceLayer::Model
    
    # The following properties are known
    # dimension_value
    # dimension_name
    
    def name
      read(:dimension_name)
    end

    def value
      read(:dimension_value)
    end

  end
end
