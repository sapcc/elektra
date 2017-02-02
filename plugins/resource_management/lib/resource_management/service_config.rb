module ResourceManagement

  # This class describes a known service from which we can pull resources.
  # The set of known ServiceConfigs is created in the all() class method.
  # Attributes include:
  #
  # - name (Symbol): the name of this service
  # - area (Symbol): used for grouping similar services in the UI
  class ServiceConfig
    attr_reader :name, :area

    def initialize(name, area)
      @name = name.to_sym
      @area = area.to_sym
    end

    def resources
      ResourceConfig.all.select { |res| res.service_name == @name }
    end

    def self.all
      return @all if @all

      @all = []
      @all << new(:compute,                   :compute)
      @all << new(:networking,                :networking)
      @all << new(:loadbalancing,             :networking)
      @all << new(:dns,                       :dns)
      @all << new(:block_storage,             :storage)
      @all << new(:object_storage,            :storage)
      @all << new(:shared_filesystem_storage, :storage)
      return @all
    end

    def self.find(name)
      name = name.to_sym
      return all.find { |s| s.name == name }
    end

    def self.in_area(area)
      area = area.to_sym
      return all.select { |s| s.area == area }
    end

    def self.mock!
      # replace services by a single, predictable mock service
      @all = [ ServiceConfig.new(:mock_service, :mock_area) ]
    end

    def self.unmock!
      @all = nil # @all will be reset in the next all() call
    end

  end

end
