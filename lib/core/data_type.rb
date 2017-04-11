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
    #     >> Core::DataType.new(:bytes, :mega).format(1024)
    #     "1 GiB"
    #     >> Core::DataType.new(:bytes, :mega).parse("1 GiB")
    #     1024
    #
    # Parsing is intended to be very forgiving. For example, the user could
    # also abbreviate "1 MiB" as "1m" for the :bytes data type.
    #
    # The following data types are known currently:
    #
    #   :number     - for values that don't have a unit (format is just #to_s and parse is just #to_i)
    #   :bytes      - for storage capacity values
    #
    # The :bytes data type also supports a sub type. For example,
    # if your base is not bytes, but megabytes, you can provide the sub type :mega
    #
    # The following sub types are known:
    #
    #   :bytes       - default
    #   :kilo, :mega, :giga, :tera, :peta, :exa
    #
    # To add a new datatype (e.g. "foo"), add the private methods "parse_foo"
    # and "format_foo", and extend ALLOWED_DATATYPES accordingly.

    ALLOWED_DATA_TYPES      = %i( number bytes ).freeze
    ALLOWED_SUB_TYPES       = %i( bytes kilo mega giga tera peta exa ).freeze
    PRETTY_FORMAT_BYTES     = %w( Bytes KiB  MiB  GiB  TiB  PiB  EiB ).freeze
    SUB_BYTES_SHORT         = %w( b     k    m    g    t    p    e   ).freeze

    def initialize(data_type, sub_type = nil)
      raise ArgumentError, "unknown data type: #{data_type.inspect}" unless ALLOWED_DATA_TYPES.include?(data_type)
      @type = data_type
      raise ArgumentError, "unknown sub type: #{sub_type.inspect}" if sub_type && !ALLOWED_SUB_TYPES.include?(sub_type)
      initialize_sub_type(sub_type)
    end

    def to_sym
      @type
    end

    def unit_name
      return "" if @type == :number
      return "B" if @target_unit_index == 0
      return PRETTY_FORMAT_BYTES[@target_unit_index]
    end

    def self.from_unit_name(unit_name)
      unit_name = unit_name.to_s
      if unit_name == ""
        return self.new(:number)
      elsif unit_name == "B"
        return self.new(:bytes)
      else
        index = PRETTY_FORMAT_BYTES.index(unit_name)
        if index != nil && index != 0
          return self.new(:bytes, ALLOWED_SUB_TYPES[index])
        end
      end
      raise ArgumentError, "unknown unit name: #{unit_name}"
    end

    def format(value, options = {delimiter: true})
      return 'Unlimited' if value < 0
      formated_value = send("format_#{@type}", value)
      unless options[:delimiter]
        formated_value.gsub!(/\u202F/,'')
      end
      formated_value
    end

    def parse(value)
      send("parse_#{@type}", value)
    end

    # If this data type is a subtype, convert the given value for the subtype
    # into the corresponding value for the base type. For example:
    #
    #    megabytes = Core::DataType.new(:bytes, :mega)
    #    bytes     = Core::DataType.new(:bytes)
    #
    #    value_megabytes = 42
    #    value_bytes     = megabytes.normalize(value_megabytes) # 45097156608
    #
    #    puts megabytes.format(value_megabytes) # "42 MiB"
    #    puts     bytes.format(value_bytes)     # still "42 MiB"
    def normalize(value)
      send("normalize_#{@type}", value)
    end

    private

    def format_number(value)
      # digit grouping separator: the SI/ISO 31-0 standard recommends to
      # separate each block of three digits by a thin space; Unicode offers the
      # narrow no-break space U+202F for this purpose
      ActiveSupport::NumberHelper.number_to_delimited(value.to_i, delimiter: "\u202F")
    end

    def format_bytes(value)
      # There is number_to_human_size() in Rails, but it is ridiculously
      # broken, even when you leave aside that they confuse SI and IEC units.
      #
      #   >> number_to_human_size(1024 * 1024)
      #   "1 MB"
      #   >> number_to_human_size(1024 * 1024 - 1)
      #   "1020 KB"
      PRETTY_FORMAT_BYTES.each_with_index do |unit, idx|
        next if idx < @target_unit_index
        # is this unit large enough? or have we reached the biggest known format?
        if value < 1024 || unit == PRETTY_FORMAT_BYTES.last
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
      raise ArgumentError, "value #{value} is not numeric" unless value =~ /\A\d+\Z/
      return value.to_i
    end

    def parse_bytes(value)
      # get rid of all whitespace, e.g. "  12 GiBytes " => "12GiBytes"
      value = value.gsub(/\s*/, '')

      # remove 'ytes' ending, e.g. "12GiBytes" => "12GiB"
      value = value.gsub(/((?:ytes)?)\Z/i, '')
      # remove 'i' in the middle, e.g. "12GiB" => "12GB"
      value = value.gsub(/(\A\d+?([.,]\d+)?(k|m|g|t|p|e)?)i+/i, '\1')
      # remove b at the end, if it is redundant, e.g. "12GB" => "12G"
      value = value.gsub(/(\A\d+?([.,]\d+)?(k|m|g|t|p|e))b?\Z/i, '\1')
      # add the correct ending if there is none, e.g. "24" => "24m"
      value += SUB_BYTES_SHORT[@target_unit_index] if value =~ /\A\d+\Z/

      # recognize units that actually change the value (e.g. "23G" -> "23" with unit = 1<<30)
      unit = 1
      SUB_BYTES_SHORT.each_with_index do |letter,idx|
        next if idx < @target_unit_index
        if value[-1].downcase == letter
          value = value[0, value.size - 1] # cut off that letter
          unit = 1 << ((idx - @target_unit_index - 1) * 10 + 10)
          break # only one unit allowed
        end
      end

      # now only a positive number should be left
      raise ArgumentError, "value #{value} is not numeric" unless value =~ /\A\d+?([.,]\d+)?\Z/
      return (value.gsub(',', '.').to_f * unit).to_i
    end

    def normalize_number(value)
      # :number does not have subtypes, so all values are normalized
      return value
    end

    def normalize_bytes(value)
      # convert values from the subtype (e.g. megabytes) into the base type (bytes)
      return value * (1 << (10 * @target_unit_index))
    end

    def initialize_sub_type(sub_type)
      return unless @type == :bytes
      # if no subtype given start with the smallest unit
      sub_type = :bytes unless sub_type
      @target_unit_index = ALLOWED_SUB_TYPES.index(sub_type)
    end
  end
end
