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
        [ 1234567890123, "1.12 TiB" ],
      ].each do |value, string|
        expect(helper.format_usage_or_quota_value(value, :bytes)).to eq(string)
      end
    end

  end

end
