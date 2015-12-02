require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the ResourceManagement::ResourceBarHelper.
RSpec.describe ResourceManagement::ResourceBarHelper, type: :helper do

  describe '#resbar_prepare_options' do

    def call_with(options)
      # convert the array returned by resbar_prepare_options() into a hash, to
      # locate its elements more easily
      a = helper.send(:resbar_prepare_options, options)
      expect(a.size).to eq(5)
      return { fill: a[0], maximum: a[1], threshold: a[2], upper_bound: a[3], warning_level: a[4] }
    end

    it 'requires that a fill value be given' do
      expect { call_with(maximum: 1)          }.to     raise_error(ArgumentError)
      expect { call_with(fill: 1, maximum: 1) }.to_not raise_error
    end

    it 'requires some kind of non-negative upper bound' do
      expect { call_with(fill: 1, maximum: +1, threshold: -1) }.to_not raise_error
      expect { call_with(fill: 1, maximum: -1, threshold: +1) }.to_not raise_error
      expect { call_with(fill: 1, maximum: -1, threshold: -1) }.to     raise_error(ArgumentError)
    end

    it 'inflates number parameters to hashes' do
      result = call_with(fill: 1, maximum: 2, threshold: 3)
      expect(     result[:fill]).to include(value: 1, label: '1')
      expect(  result[:maximum]).to include(value: 2, label: '2')
      expect(result[:threshold]).to include(value: 3, label: '3')
    end

    it 'renders custom labels' do
      result = call_with(
        fill:      { value: 23, label: "fill = ($VALUE)" },
        maximum:   { value: 42, label: "maximum = ($VALUE)" },
        threshold: { value: 65, label: "threshold = ($VALUE)" },
      )
      expect(     result[:fill]).to include(value: 23, label:      'fill = (23)')
      expect(  result[:maximum]).to include(value: 42, label:   'maximum = (42)')
      expect(result[:threshold]).to include(value: 65, label: 'threshold = (65)')
    end

    it 'sets maximum = fill and threshold = maximum by default' do
      result = call_with(fill: 1)
      expect(     result[:fill]).to include(value: 1)
      expect(  result[:maximum]).to include(value: 1)
      expect(result[:threshold]).to include(value: 1)

      result = call_with(fill: 1, maximum: 2)
      expect(     result[:fill]).to include(value: 1)
      expect(  result[:maximum]).to include(value: 2)
      expect(result[:threshold]).to include(value: 2)
    end

    it 'uses the display_unit option to calculate labels' do
      result = call_with(
        fill:         23552,
        maximum:      { value: 43008 },
        threshold:    { value: 66560, label: 'foo$VALUEbar' },
        display_unit: 1024,
      )

      expect(     result[:fill]).to include(label: '23')
      expect(  result[:maximum]).to include(label: '42')
      expect(result[:threshold]).to include(label: 'foo65bar')
    end

    it 'recognizes the warning_level option' do
      expect(call_with(fill: 1, warning_level: 0.5)).to include(warning_level: 0.5)
    end

    it 'uses a reasonable default warning_level' do
      result = call_with(fill: 1)
      expect(result).to include(:warning_level)
      expect(result[:warning_level]).to be > 0
      expect(result[:warning_level]).to be < 1
    end

    it 'computes the upper bound and size percentages for rendering' do
      # for positive maximum and threshold, upper_bound = maximum
      result = call_with(fill: 20, maximum: 40, threshold: 50)

      expect(result[:upper_bound]).to eq(40)
      expect(result[:fill]).to      include(value: 20, percent:  50)
      expect(result[:threshold]).to include(value: 50, percent: 125)

      # for negative threshold, still upper_bound = maximum
      result = call_with(fill: 20, maximum: 40, threshold: -50)

      expect(result[:upper_bound]).to eq(40)
      expect(result[:fill]).to      include(value:  20, percent:   50)
      expect(result[:threshold]).to include(value: -50, percent:    0) # percent is never less than 0

      # for negative maximum, use instead upper_bound = threshold
      result = call_with(fill: 20, maximum: -40, threshold: 50)

      expect(result[:upper_bound]).to eq(50)
      expect(result[:fill]).to      include(value: 20, percent:  40)
      expect(result[:threshold]).to include(value: 50, percent: 100)
    end

  end

end

