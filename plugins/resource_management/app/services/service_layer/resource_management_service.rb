module ServiceLayer

  class ResourceManagementService < DomainModelServiceLayer::Service

    def init(params)
      @driver = ResourceManagement::Driver::MyDriver.new(params)
      raise "Error" unless @driver.is_a?(ResourceManagement::Driver::Interface)
    end
    
    def test
      @driver.test
    end
  end
end