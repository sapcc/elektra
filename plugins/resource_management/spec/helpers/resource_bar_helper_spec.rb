require 'spec_helper'
require 'core/data_type'

# Specs in this file have access to a helper object that includes
# the ResourceManagement::ResourceBarHelper.
RSpec.describe ResourceManagement::ResourceBarHelper, type: :helper do

  describe '#resbar_prepare_options' do

    def call_with(options)
      # convert the array returned by resbar_prepare_options() into a hash, to
      # locate its elements more easily
      a = helper.send(:resbar_prepare_options, options)
      expect(a.size).to eq(7)
      return { fill: a[0], maximum: a[1], threshold: a[2], upper_bound: a[3], warning_level: a[4], danger_level:a[5], marker: a[6]}
    end

    it 'requires that a fill value be given' do
      expect { call_with(maximum: 1)          }.to     raise_error(ArgumentError)
      expect { call_with(fill: 1, maximum: 1) }.to_not raise_error
    end

    it 'requires some kind of non-negative upper bound' do
      expect { call_with(fill: 1, maximum: +1, threshold: -1) }.to_not raise_error
      expect { call_with(fill: 1, maximum: -1, threshold: +1) }.to_not raise_error
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

    it 'uses the data_type option to render labels' do
      result = call_with(
        fill:      23552,
        maximum:   { value: 43008 },
        threshold: { value: 66560, label: 'foo bar: $VALUE' },
        data_type: Core::DataType.new(:bytes),
      )

      expect(     result[:fill]).to include(label: '23 KiB')
      expect(  result[:maximum]).to include(label: '42 KiB')
      expect(result[:threshold]).to include(label: 'foo bar: 65 KiB')
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

      # upper_bound = 0 is possible if maximum = 0
      result = call_with(fill: 0, maximum: 0, threshold: 10)

      expect(result[:upper_bound]).to eq(0)
      expect(result[:fill]).to include(value: 0, percent: 0)
    end

  end

  describe '#resbar_compile_bars' do

    def bars_for(options)
      fill, maximum, threshold, _, warning_level, danger_level, marker = helper.send(:resbar_prepare_options, options)
      return helper.send(:resbar_compile_bars, fill, maximum, threshold, warning_level, danger_level, marker)
    end

    it 'renders a single plain bar for fill < maximum and no threshold' do
      [
        [  40, 'default' ],
        [  79, 'default' ],
        [  80, 'warning' ],
        [  99, 'warning' ],
        [ 100, 'danger'  ],
      ].each do |fill, type|
        expect(bars_for(fill: fill, maximum: 100, warning_level: 0.8)).to contain_exactly(
          { type: type, label: fill.to_s, percent: fill == 100 ? 99.9 : fill },
        )
      end
    end

    it 'renders the label next to the bar for short bars' do
      expect(bars_for(fill: 0, maximum: 100)).to contain_exactly(
        { type: 'empty', percent: 99.9, label: '0' },
      )
      expect(bars_for(fill: 1, maximum: 100)).to contain_exactly(
        { type: 'default', percent: 1 },
        { type: 'empty',   percent: 98.9, label: '1' },
      )
    end

    it 'marks the empty area beyond the threshold for threshold < maximum' do
      expect(bars_for(fill: 25, maximum: 100, threshold: 100)).to contain_exactly(
        { type: 'default', percent: 25, label: '25' },
      )
      expect(bars_for(fill: 25, maximum: 100, threshold:  60)).to contain_exactly(
        { type: 'default',          percent: 25, label: '25' },
        { type: 'empty',            percent: 35 }, # skip forward to where the threshold starts
        { type: 'empty-overcommit', percent: 39.9 },
      )
      expect(bars_for(fill: 60, maximum: 100, threshold:  60)).to contain_exactly(
        { type: 'danger',           percent: 60, label: '60' }, # danger because fill approached threshold
        { type: 'empty-overcommit', percent: 39.9 },
      )
    end

    it 'marks the filled area beyond the threshold' do
      expect(bars_for(fill: 85, maximum: 100, threshold:  60)).to contain_exactly(
        { type: 'danger',            percent: 60, label: '85' },
        { type: 'danger-overcommit', percent: 25 },
        { type: 'empty-overcommit',  percent: 14.9 },
      )
      expect(bars_for(fill: 100, maximum: 100, threshold:  60)).to contain_exactly(
        { type: 'danger',            percent: 60, label: '100' },
        { type: 'danger-overcommit', percent: 39.9 },
      )
    end

    it 'can skip multiple bars when looking for where to put the label' do
      expect(bars_for(fill: 1, threshold: 3, maximum: 100)).to contain_exactly(
        { type: 'default',          percent: 1  },
        { type: 'empty',            percent: 2, label: '1' },
        { type: 'empty-overcommit', percent: 96.9 },
      )
      expect(bars_for(fill: 1, threshold: 2, maximum: 100)).to contain_exactly(
        { type: 'default',          percent: 1 },
        { type: 'empty',            percent: 1 },
        { type: 'empty-overcommit', percent: 97.9, label: '1' },
      )
    end

    it 'uses the threshold as upper bound when maximum < 0' do
      expect(bars_for(fill: 0, maximum: -1, threshold: 50)).to contain_exactly(
        # for maximum < 0, mark all empty area as overcommit
        { type: 'empty-overcommit', percent: 99.9, label: '0' },
      )
      expect(bars_for(fill: 10, maximum: -1, threshold: 50)).to contain_exactly(
        { type: 'default',          percent: 20, label: '10' },
        { type: 'empty-overcommit', percent: 79.9 },
      )
      expect(bars_for(fill: 50, maximum: -1, threshold: 50)).to contain_exactly(
        { type: 'danger',            percent: 99.9, label: '50' },
      )
      expect(bars_for(fill: 200, maximum: -1, threshold: 50)).to contain_exactly(
        { type: 'danger',            percent: 25, label: '200' },
        { type: 'danger-overcommit', percent: 74.9 },
      )
    end

    it 'shows an empty bar with overcommit indication for fill = maximum = 0' do
      expect(bars_for(fill: 0, maximum: 0)).to contain_exactly(
        { type: 'empty-overcommit', percent: 99.9, label: '0' },
      )

      expect(bars_for(fill: 0, maximum: 0, threshold: 1)).to contain_exactly(
        { type: 'empty-overcommit', percent: 99.9, label: '0' },
      )
    end

    it 'handles threshold = 0 correctly' do
      expect(bars_for(fill: 10, threshold: 0, maximum: 25)).to contain_exactly(
        { type: 'danger-overcommit', percent: 40, label: '10' },
        { type: 'empty-overcommit',  percent: 59.9 },
      )
    end

  end

end
