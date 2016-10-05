module ResourceManagement
  class QuotaData
    attr_reader :name, :usage, :total, :data_type
    def initialize(options={})
      @name      = options[:name]
      @usage     = options[:usage].to_i
      @total     = options[:total].to_i
      @data_type = options[:data_type]
    end

    def available
      total - usage
    end

    def display_string
      "#{@data_type.format(available)} #{I18n.t("resource_management.#{@name}")}"
    end
  end
end
