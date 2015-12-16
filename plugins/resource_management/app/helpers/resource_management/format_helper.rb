module ResourceManagement
  module FormatHelper

    def format_usage_or_quota_value(value, data_type=nil)
      if data_type.nil?
        return value.to_i.to_s
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

    def parse_usage_or_quota_value(value, data_type=nil)
      if data_type.nil?
        # value must be a positive integer (or 0), but ignore surrounding whitespace
        value = value.sub(/\A\s+/, '').sub(/\s+\Z/, '')
        raise ArgumentError, "value #{value} is not numeric" unless value.match(/\A\d+\Z/)
        return value.to_i
      elsif data_type == :bytes
        return parse_bytes_value(value)
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

    def parse_bytes_value(value)
      # get rid of all whitespace, e.g. "  12 GiB " => "12GiB"
      value = value.gsub(/\s*/, '')

      # remove units that don't actually change the value, e.g. "5Bytes" => "5", "23GiB" => "23G"
      value = value.gsub(/(?i:i?b(?:ytes)?)\Z/, '')

      # recognize units that actually change the value (e.g. "23G" -> "23" with unit = 1<<30)
      unit = 1
      %w[ k m g t p e ].each_with_index do |letter,idx|
        if value[-1].downcase == letter
          value = value[0, value.size - 1] # cut off that letter
          unit = 1 << (idx * 10 + 10)
          break # only one unit allowed
        end
      end

      # now only a positive number should be left
      raise ArgumentError, "value #{value} is not numeric" unless value.match(/\A\d+?([.,]\d+)?\Z/)
      return (value.gsub(',', '.').to_f * unit).to_i
    end

  end
end
