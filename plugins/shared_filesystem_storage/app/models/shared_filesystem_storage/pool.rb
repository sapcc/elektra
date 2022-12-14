# frozen_string_literal: true

module SharedFilesystemStorage
  class Pool < Core::ServiceLayer::Model
    def aggregate
      read("pool")
    end

    def total_capacity
      Core::DataType.new(:bytes, :giga).format(
        capabilities["total_capacity_gb"],
      )
    end

    def allocated_capacity
      Core::DataType.new(:bytes, :giga).format(
        capabilities["allocated_capacity_gb"],
      )
    end

    # stree-ignore
    def allocated_capacity_percentage
      (capabilities['allocated_capacity_gb'] / capabilities['total_capacity_gb'] * 100).round(2)
    end

    def free_capacity
      Core::DataType.new(:bytes, :giga).format(
        capabilities["free_capacity_gb"] - reserved_capacity_float,
      )
    end

    # stree-ignore
    def free_capacity_percentage
      ((capabilities['free_capacity_gb'] / capabilities['total_capacity_gb'] * 100) - reserved_capacity_percentage).round(2)
    end

    def reserved_capacity
      Core::DataType.new(:bytes, :giga).format(reserved_capacity_float)
    end

    def reserved_capacity_percentage
      capabilities["reserved_percentage"]
    end

    private

    def reserved_capacity_float
      (
        capabilities["reserved_percentage"] * capabilities["total_capacity_gb"]
      ) / 100
    end
  end
end
