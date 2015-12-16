require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the ResourceManagement::FormatHelper.
RSpec.describe ResourceManagement::FormatHelper, type: :helper do

  describe '#format_usage_or_quota_value' do

    it 'just stringifies when no data type given' do
      expect(helper.format_usage_or_quota_value(42)).to eq('42')
      expect(helper.format_usage_or_quota_value(42, nil)).to eq('42')
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
        expect(helper.format_usage_or_quota_value(value, :bytes)).to eq(string)
      end
    end

    it 'handles float values correctly' do 
      expect(helper.format_usage_or_quota_value(5.0, nil)).to eq("5")
    end

    it 'fails with unknown datatype' do
      expect { helper.format_usage_or_quota_value(42, :foo) }.to raise_error(ArgumentError)
      expect { helper.format_usage_or_quota_value(42,  23) }.to raise_error(ArgumentError)
    end

  end

  describe '#parse_usage_or_quota_value' do

    it 'accepts non-negative integers only when no data type given' do

      expect(helper.parse_usage_or_quota_value("52", nil)).to eq(52)
      expect(helper.parse_usage_or_quota_value("52")).to eq(52)
      expect(helper.parse_usage_or_quota_value("0")).to eq(0)
      expect(helper.parse_usage_or_quota_value("1234567890")).to eq(1234567890)

      expect(helper.parse_usage_or_quota_value("    0004  ")).to eq(4)

      expect { helper.parse_usage_or_quota_value("foo") }.to raise_error(ArgumentError)
      expect { helper.parse_usage_or_quota_value("4 things") }.to raise_error(ArgumentError)
      expect { helper.parse_usage_or_quota_value("4 GiB") }.to raise_error(ArgumentError)

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
                  expect(helper.parse_usage_or_quota_value(repr5, :bytes)).to eq(value)
                end
              end
            end
          end
        end
      end

      # check some incorrect values
      expect { helper.parse_usage_or_quota_value("foo",      :bytes) }.to raise_error(ArgumentError)
      expect { helper.parse_usage_or_quota_value("4 things", :bytes) }.to raise_error(ArgumentError)
    end

  end

end
