module ResourceManagement
  module FormatHelper

    def format_usage_or_quota_value(value, data_type=nil)
      return ResourceManagement::DataType.new(data_type || :number).format(value)
    end

    def parse_usage_or_quota_value(value, data_type=nil)
      return ResourceManagement::DataType.new(data_type || :number).parse(value)
    end

  end
end
