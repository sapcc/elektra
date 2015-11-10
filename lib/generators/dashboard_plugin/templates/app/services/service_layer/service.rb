module ServiceLayer

  class %{PLUGIN_NAME}Service < DomainModelServiceLayer::Service

    def init(params)
      @driver = %{PLUGIN_NAME}::Driver::MyDriver.new(params)
      raise "Error" unless @driver.is_a?(%{PLUGIN_NAME}::Driver::Interface)
    end
    
    def test
      @driver.test
    end
  end
end