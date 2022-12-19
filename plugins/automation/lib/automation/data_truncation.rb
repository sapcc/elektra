module Automation
  class DataTruncation
    LINES_TRUNCATION = 25
    NO_DATA_FOUND = "No data available."

    attr_reader :data_lines, :data_truncated, :data_output

    def initialize(data = nil)
      @data_lines = 1
      @data_truncated = false
      @data_output = NO_DATA_FOUND
      process_data(data)
    end

    def process_data(data)
      unless data.blank?
        pretty_data = prettify(data)
        @data_lines = pretty_data.lines.count
        @data_truncated = @data_lines > LINES_TRUNCATION
        @data_output = pretty_data.lines.last(LINES_TRUNCATION).join
      end
    end

    def data_truncated?
      data_truncated
    end

    private

    def prettify(data)
      begin
        json = JSON.parse(data)
        JSON.pretty_generate(json)
      rescue JSON::ParserError
        data
      end
    end
  end
end
