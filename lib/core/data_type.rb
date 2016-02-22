module Core
  class DataType

    # This class provides formatting for values presented to the user, and
    # parsing of user input for the same data types.
    #
    #     >> Core::DataType.new(:bytes).format(1048576)
    #     "1 MiB"
    #     >> Core::DataType.new(:bytes).parse("1 MiB")
    #     1048576
    #
    # Parsing is intended to be very forgiving. For example, the user could
    # also abbreviate "1 MiB" as "1m" for the :bytes data type.
    #
    # The following data types are known currently:
    #
    #   :number     - for values that don't have a unit (format is just #to_s and parse is just #to_i)
    #   :bytes      - for storage capacity values
    #
    # To add a new datatype (e.g. "foo"), add the private methods "parse_foo"
    # and "format_foo", and extend ALLOWED_DATATYPES accordingly.

    ALLOWED_DATA_TYPES = [ :number, :bytes ]

    def initialize(data_type)
      raise ArgumentError, "unknown data type: #{data_type.inspect}" unless ALLOWED_DATA_TYPES.include?(data_type)
      @type = data_type
    end

    def to_sym
      @type
    end

    def format(value)
      send("format_#{@type}", value)
    end

    def parse(value)
      send("parse_#{@type}", value)
    end

    private

    def format_number(value)
      return value.to_i.to_s
    end

    def format_bytes(value)
      # There is number_to_human_size() in Rails, but it is ridiculously
      # broken, even when you leave aside that they confuse SI and IEC units.
      #
      #   >> number_to_human_size(1024 * 1024)
      #   "1 MB"
      #   >> number_to_human_size(1024 * 1024 - 1)
      #   "1020 KB"
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

    def parse_number(value)
      value = value.sub(/\A\s+/, '').sub(/\s+\Z/, '')
      raise ArgumentError, "value #{value} is not numeric" unless value.match(/\A\d+\Z/)
      return value.to_i
    end

    def parse_bytes(value)
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
