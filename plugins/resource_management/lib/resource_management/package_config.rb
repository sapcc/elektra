module ResourceManagement

  # This class describes the pre-defined values for a resource's quota in the
  # pre-defined quota packages (aka "t-shirt sizes"). Attributes include:
  #
  # - significant? (Boolean):    whether this resource on the package comparison table
  # - values       (Array[Int]): the quota values for each package (packages are listed in `PACKAGES`)

  class PackageConfig
    # NOTE: when adding new packages, please also add the human-readable name to plugins/resource_management/config/locales/en.yml
    PACKAGES = ['S', 'M', 'L']

    attr_reader :values

    def initialize(significant, *values)
      @significant = significant
      @values = values
    end

    def significant?
      @significant
    end

    def value_for_package(package)
      idx = PACKAGES.index(package)
      raise ArgumentError, "\"#{package}\": no such package" if idx.nil?
      return @values[idx]
    end
  end

end
