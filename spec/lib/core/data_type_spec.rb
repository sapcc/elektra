require 'active_support'
require 'core/data_type'

RSpec.describe Core::DataType do

  let(:datatype_number)     { Core::DataType.new(:number)       }
  let(:datatype_bytes)      { Core::DataType.new(:bytes)        }
  let(:datatype_mega_bytes) { Core::DataType.new(:bytes, :mega) }

  describe '#format' do

    it 'renders number values as plain numbers' do
      expect(datatype_number.format(0)).to    eq('0')
      expect(datatype_number.format(42)).to   eq('42')
      expect(datatype_number.format(123)).to  eq('123')
    end

    it 'inserts spaces to group digits in large numbers' do
      # NOTE: the patterns need [[:space:]] instead of \s to recognize Unicode whitespace characters
      expect(datatype_number.format(12345)).to     match(/^12[[:space:]]345$/)
      expect(datatype_number.format(1234567)).to   match(/^1[[:space:]]234[[:space:]]567$/)
      expect(datatype_number.format(123456789)).to match(/^123[[:space:]]456[[:space:]]789$/)
      # check with no delimiter (used for editable fields)
      expect(datatype_number.format(12345, delimiter: false)).to     match(/^12345$/)
      expect(datatype_number.format(1234567, delimiter: false)).to   match(/^1234567$/)
      expect(datatype_number.format(123456789, delimiter: false)).to match(/^123456789$/)
    end

    it 'renders byte values with appropriate units' do
      [
        [ 42, "42 Bytes" ],
        [ 1000, "1000 Bytes" ],
        [ 1024, "1 KiB" ],
        [ 1234567, "1.18 MiB" ],
        [ 1234567890, "1.15 GiB" ],
        [ 45421255555, "42.3 GiB" ],
        [ 1234567890123, "1.12 TiB" ],
      ].each do |value, string|
        expect(datatype_bytes.format(value)).to eq(string)
      end
    end

    it 'renders mega-byte values with appropriate units' do
      [
        [ 1, "1 MiB" ],
        [ 1234, "1.21 GiB" ],
        [ 45421, "44.36 GiB" ],
        [ 1234567, "1.18 TiB" ],
      ].each do |value, string|
        expect(datatype_mega_bytes.format(value)).to eq(string)
      end
    end

    it 'handles float values correctly' do
      expect(datatype_number.format(5.0)).to eq('5')
    end

    it 'fails with unknown datatype' do
      expect { Core::DataType.new(:foo) }.to raise_error(ArgumentError)
      expect { Core::DataType.new(23) }.to raise_error(ArgumentError)
    end

    it 'fails with unknown bytes subtype' do
      expect { Core::DataType.new(:bytes, :magra) }.to raise_error(ArgumentError)
    end

  end

  describe '#parse' do

    it 'accepts non-negative integers only for data type number' do

      expect(datatype_number.parse("52")).to eq(52)
      expect(datatype_number.parse("0")).to eq(0)
      expect(datatype_number.parse("1234567890")).to eq(1234567890)

      expect(datatype_number.parse("    0004  ")).to eq(4)

      expect { datatype_number.parse("foo") }.to raise_error(ArgumentError)
      expect { datatype_number.parse("4 things") }.to raise_error(ArgumentError)
      expect { datatype_number.parse("4 GiB") }.to raise_error(ArgumentError)

    end

    it 'parses byte values correctly' do
      [
        [ "0",          0 ],
        [ "0 Bytes",    0 ],
        [ "00042",      42 ],
        [ "42 Bytes",   42 ],
        [ "1000 Bytes", 1000 ],
        [ "1 KiB",      1024 ],
        [ "1.18 MiB",   1237319 ],
        [ "1.15 GiB",   1234803097 ],
        [ "42.3 GiB",   45419279155 ],
        [ "1.12 TiB",   1231453023109 ],
      ].each do |string, value|
        # check multiple representations of the same input
        # 1. with comma or dot
        [ string, string.sub(/\./, ',') ].uniq.each do |repr1|
          # 2. with space between value and unit removed
          [ repr1, repr1.gsub(/\s+/, '') ].uniq.each do |repr2|
            # 3. with extra surrounding space
            [ repr2, "  #{repr2}\n" ].each do |repr3|
              # 4. with units like "KiB" shortened to "KB" or "K"
              [ repr3, repr3.sub("iB", "B"), repr3.sub("iB", "") ].uniq.each do |repr4|
                # 5. with units in all lowercase or all uppercase
                [ repr4, repr4.downcase, repr4.upcase ].uniq.each do |repr5|
                  expect(datatype_bytes.parse(repr5)).to eq(value)
                end
              end
            end
          end
        end
      end

      # check some incorrect values
      expect { datatype_bytes.parse("foo")      }.to raise_error(ArgumentError)
      expect { datatype_bytes.parse("4 things") }.to raise_error(ArgumentError)
    end

    it 'parses mega-byte values correctly' do
      [
        [ "0",          0 ],
        [ "0 MiB",      0 ],
        [ "1.21 GiB",   1239 ],
        [ "44.61 GiB",  45680 ],
        [ "1.177 TiB",  1234173 ],
      ].each do |string, value|
        # check multiple representations of the same input
        # 1. with comma or dot
        [ string, string.sub(/\./, ',') ].uniq.each do |repr1|
          # 2. with space between value and unit removed
          [ repr1, repr1.gsub(/\s+/, '') ].uniq.each do |repr2|
            # 3. with extra surrounding space
            [ repr2, "  #{repr2}\n" ].each do |repr3|
              # 4. with units like "MiB" shortened to "MB" or "M"
              [ repr3, repr3.sub("iB", "B"), repr3.sub("iB", "") ].uniq.each do |repr4|
                # 5. with units in all lowercase or all uppercase
                [ repr4, repr4.downcase, repr4.upcase ].uniq.each do |repr5|
                  expect(datatype_mega_bytes.parse(repr5)).to eq(value)
                end
              end
            end
          end
        end
      end

      # check some incorrect values
      expect { datatype_mega_bytes.parse("8 k")     }.to raise_error(ArgumentError)
      expect { datatype_mega_bytes.parse("16 mk")   }.to raise_error(ArgumentError)
      expect { datatype_mega_bytes.parse("4 bytes") }.to raise_error(ArgumentError)
    end
  end

  describe '#normalize' do

    it 'is a no-op for the base datatypes' do
      [ 0, 42, 1234567 ].each do |value|
        expect(datatype_number.normalize(value)).to eq(value)
        expect(datatype_bytes.normalize(value)).to eq(value)
      end
    end

    it 'promotes megabytes to bytes' do
      [ 0, 42, 1234567 ].each do |value|
        expect(datatype_mega_bytes.normalize(value)).to eq(value * 1024 * 1024)
      end
    end

  end

  describe '#unit_name' do

    it 'serializes the unit name used by Limes' do
      expect(Core::DataType.new(:number).unit_name).to eq("")
      expect(Core::DataType.new(:bytes).unit_name).to eq("B")
      expect(Core::DataType.new(:bytes, :kilo).unit_name).to eq("KiB")
      expect(Core::DataType.new(:bytes, :mega).unit_name).to eq("MiB")
      expect(Core::DataType.new(:bytes, :giga).unit_name).to eq("GiB")
      expect(Core::DataType.new(:bytes, :tera).unit_name).to eq("TiB")
      expect(Core::DataType.new(:bytes, :peta).unit_name).to eq("PiB")
      expect(Core::DataType.new(:bytes,  :exa).unit_name).to eq("EiB")
    end

  end

  describe '#from_unit_name' do

    it 'is the reverse of #unit_name' do
      ["","B","KiB","MiB","GiB","TiB","PiB","EiB"].each do |unit|
        expect(Core::DataType.from_unit_name(unit).unit_name).to eq(unit)
      end
    end

    it 'does not accept anything else' do
      ["blargh","kb","G","Bytes",42].each do |unit|
        expect { Core::DataType.from_unit_name(unit) }.to raise_error(ArgumentError)
      end
    end

  end

end
