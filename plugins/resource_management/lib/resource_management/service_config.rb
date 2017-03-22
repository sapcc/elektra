module ResourceManagement

  # This class describes a known service from which we can pull resources.
  # The set of known ServiceConfigs is created in the all() class method.
  # Attributes include:
  #
  # - name (Symbol): the name of this service
  # - area (Symbol): used for grouping similar services in the UI
  # - catalog_type (String): the "type" attribute of this service in the Keystone catalog
  class ServiceConfig
    attr_reader :name, :area, :catalog_type

    def initialize(name, area, catalog_type)
      @name = name.to_sym
      @area = area.to_sym
      @catalog_type = catalog_type.to_s
    end

    def resources
      ResourceConfig.all.select { |res| res.service_name == @name }
    end

    def self.all
      return @all if @all

      @all = []
      @all << new(:compute,                   :compute,    'compute')
      @all << new(:networking,                :networking, 'network')
      @all << new(:loadbalancing,             :networking, 'network')
      @all << new(:dns,                       :dns,        'dns')
      @all << new(:block_storage,             :storage,    'volumev2')
      @all << new(:object_storage,            :storage,    'object-store')
      @all << new(:shared_filesystem_storage, :storage,    'sharev2')
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
      @all = [ ServiceConfig.new(:mock_service, :mock_area, 'mock_service') ]
    end

    def self.unmock!
      @all = nil # @all will be reset in the next all() call
    end

  end

end
