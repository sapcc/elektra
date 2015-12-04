module ResourceManagement
  module FormatHelper

    def format_usage_or_quota_value(value, data_type=nil)
      if data_type.nil?
        return value.to_s
      elsif data_type == :bytes
        # There is number_to_human_size() in Rails, but it is ridiculously
        # broken, even when you leave aside that they confuse SI and IEC units.
        #
        #   >> number_to_human_size(1024 * 1024)
        #   "1 MB"
        #   >> number_to_human_size(1024 * 1024 - 1)
        #   "1020 KB"
        return format_bytes_value(value)
      else
        raise ArgumentError, "unknown data_type: #{data_type.class.to_s} #{data_type.inspect}"
      end
    end

    private

    def format_bytes_value(value)
      %w[ Bytes KiB MiB GiB TiB PiB EiB ].each do |unit|
        # is this unit large enough?
        if value < 1024
          str = "%.2f" % value
          str.sub!(/[.]?0+$/, '') if str =~ /[.]/ # strip trailing zeros after dot
          return "#{str} #{unit}"
        end
        # if not, obtain the value for the next unit
        value = value.to_f / 1024
      end
    end

  end
end
