module DomainModel

  class %{PLUGIN_NAME}Service < DomainModelServiceLayer::Service

    def get_driver(params)
      driver = %{PLUGIN_NAME}::Driver::MyDriver.new(params)
      raise "Error" unless driver.is_a?(%{PLUGIN_NAME}::Driver::Interface)
      driver
    end
    
    def test
      @driver.test
    end
  end
end