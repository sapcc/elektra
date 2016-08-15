module Automation

  class DataTruncation

    LINES_TRUNCATION = 25
    NO_DATA_FOUND = 'No data available.'

    attr_reader :data, :data_lines, :data_truncated, :data_output

    def initialize(data=nil)
      @data = data
      @data_lines = 1
      @data_truncated = false
      @data_output = NO_DATA_FOUND
      process_data
    end

    def process_data
      unless @data.blank?
        @data_lines = @data.lines.count
        @data_truncated = @data_lines > LINES_TRUNCATION
        @data_output = @data.lines.last(LINES_TRUNCATION).join
      end
    end

    def data_truncated?
      data_truncated
    end

  end

end